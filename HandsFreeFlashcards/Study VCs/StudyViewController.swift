//
//  StudyViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 11/10/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import CoreData


class StudyViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate  {

    @IBOutlet weak var wordLabel: UILabel!

    var studySets: [Set]?
    var firstChoiceIndex = 1
    var secondChoiceIndex = 2
    
    var studyMode:Mode = .answer
    var repeatIncorrect = false
    //var defFirst = false
    
    var cards = [Card]()
    var numArray = [Int]()
    var sideOneSet = [(term: String, langID: String)]()
    var sideTwoSet = [(term: String, langID: String)]()
    var currentSide = 1
    var currentCardIndex = 0
    

    var incorrectNumArray = [Int]()
    var currNumArray = [Int]()
    
    var sideOneShowing = false
    var saidSideTwo = true
    var saidSideOne = true
    var managedObjectContext: NSManagedObjectContext?
    var gotCards = false
    var visible = false
    var restarting = false
    var timer:Timer?
    //text to speech
    private let synth = AVSpeechSynthesizer()
    private var utterance = AVSpeechUtterance(string:"")
    
    //voice recognition
    private var speechRecognizer = SFSpeechRecognizer(locale:Locale(identifier:"en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabel.text = ""
        synth.delegate = self
        getCards()
    }
    private func getCards() {
        if (studySets == nil) {
            print("studySet is nil")
            return
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
                for studySet in self.studySets! {
                    if studySet.setName != nil, self.managedObjectContext != nil {
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
                        request.predicate = NSPredicate(format: "parentSet.setName = %@", studySet.setName!)
                        if let fetchedCards = (try? self.managedObjectContext!.fetch(request)) as? [Card] {
                            self.cards = fetchedCards
                        }
                    }
                    if (self.cards.isEmpty) {
                        self.wordLabel.text = "Please choose a nonempty study set."
                        return
                    }
                    self.gotCards = true
                
                    for card in self.cards {
                        switch self.firstChoiceIndex {
                        case 1:
                            if card.sideOne != nil, studySet.sideOneLangID != nil {
                                self.sideOneSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                            }
                        case 2:
                            if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                self.sideOneSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                            }
                        case 3:
                            if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                self.sideOneSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                            }
                        default:
                            print("invalid firstChoiceIndex")
                        }
                        switch self.secondChoiceIndex {
                        case 1:
                            if card.sideOne != nil, studySet.sideOneLangID != nil {
                                self.sideTwoSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                            }
                        case 2:
                            if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                self.sideTwoSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                            }
                        case 3:
                            if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                self.sideTwoSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                            }
                        default:
                            print("invalid firstChoiceIndex")
                        }
                    }
                    for num in 0..<self.cards.count {
                        self.numArray.append(num)
                    }
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization {
            authStatus in
            OperationQueue.main.addOperation {
                switch authStatus{
                case .authorized:
                    break
                case .denied:
                    self.wordLabel.text = "Recognition authorization not granted"
                    return
                case .restricted:
                    self.wordLabel.text = "Recognition restricted"
                    return
                case .notDetermined:
                    self.wordLabel.text = "Recognition authorization no yet granted"
                    return
                }
            }
        }
        DispatchQueue.main.async {
            if self.gotCards {
                self.currNumArray = self.numArray
                self.saidSideOne = true
                self.saySideOne()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visible = false
        if timer != nil && timer!.isValid {
            timer!.invalidate()
        }
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            }
            catch {
                print("failed to inactivate session")
            }
        }
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }
        //TODO: CHECK IF VOICE STILL BEING RECORDED AFTER LEAVING SCREEN (EVEN THOUGH NOT RESPONDING TO IT)
    }
    
    private func inactivateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            print("failed to inactivate session")
        }
    }
    private func startRecording() throws {
        speechRecognizer = SFSpeechRecognizer(locale:Locale(identifier:self.sideTwoSet[self.currentCardIndex].langID))!

        if let currRecognitionTask = recognitionTask {
            currRecognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with:.notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        if recognitionRequest == nil {
            fatalError("Unable to create an SFSpeechAudioBufferRequest object")
        }
        
        recognitionRequest?.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) {
            result, error in
            var isFinal = false //TODO: NEED THIS VARIABLE?
            if (result != nil) {
                let result = result!.bestTranscription.formattedString //check for correct answer
                if (self.sideOneShowing && self.studyMode != .rep) {
                    if (result.lowercased() != self.sideTwoSet[self.currentCardIndex].term.lowercased()) {
                        //play incorrect sound
                        if (self.repeatIncorrect) {
                            self.incorrectNumArray.append(self.currentCardIndex)
                        }
                    }
                    else {
                        //play correct sound
                    }
                }
                isFinal = true
            }
            if (error != nil || isFinal) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionTask?.cancel()
                self.recognitionRequest = nil
                self.recognitionTask = nil
                if (!self.saidSideTwo && self.sideOneShowing) {
                    self.saidSideTwo = true
                    self.saySideTwo() //TODO: NEED WEAKSELF HERE?
                }
                else if (!self.saidSideOne && !self.sideOneShowing) {
                    self.saidSideOne = true
                    self.saySideOne()
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    private func resetAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try audioSession.setActive(true, with:.notifyOthersOnDeactivation)
    }

    private func saySideOne() {
        do {
            try resetAudioSession()
        }
        catch {
            print("error resetting audio session")
        }
        if (currNumArray.isEmpty) {
            restarting = true
            if (studyMode != .rep && !incorrectNumArray.isEmpty) {
                currNumArray = incorrectNumArray
                if incorrectNumArray.count == 1 {
                    utterance = AVSpeechUtterance(string: "Starting over with " + String(incorrectNumArray.count) + "incorrect word.")
                }
                else {
                    utterance = AVSpeechUtterance(string: "Starting over with " + String(incorrectNumArray.count) + "incorrect words.")
                }
                incorrectNumArray = [Int]()
            }
            else {
                currNumArray = numArray
                utterance = AVSpeechUtterance(string: "Round complete. Starting over.")
            }
            utterance.voice = AVSpeechSynthesisVoice(language:"en-US")
            utterance.rate = 0.4
            synth.speak(utterance)
        }
        let randomOffset = Int(arc4random_uniform(UInt32(currNumArray.count)))
        currentCardIndex = currNumArray[randomOffset]
        //TODO: NEED PERFORM AND WAIT HERE?
        let currWord = sideOneSet[currentCardIndex].term
        wordLabel.text = currWord
        sideOneShowing = true
        currNumArray.remove(at:randomOffset)
        
        utterance = AVSpeechUtterance(string: currWord)
        utterance.voice = AVSpeechSynthesisVoice(language:sideOneSet[currentCardIndex].term)
        utterance.rate = 0.4
        synth.speak(utterance)

    }
    
    private func saySideTwo() {
        do {
            try resetAudioSession()
        }
        catch {
            print("error resetting audio session")
        }
        let currWord = sideTwoSet[currentCardIndex].term
        wordLabel.text = currWord
        sideOneShowing = false
        
        utterance = AVSpeechUtterance(string: currWord)
        utterance.voice = AVSpeechSynthesisVoice(language:sideTwoSet[currentCardIndex].langID)
        utterance.rate = 0.4
        synth.speak(utterance)
    }
    
    // MARK: AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !visible {
            return
        }
        if restarting {
            restarting = false
            return
        }
        if sideOneShowing {
            if studyMode == .rep {
                self.saySideTwo()
            }
            else if studyMode == .noVoice {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (t:Timer) in self.saySideTwo() }
            }
            else {
                self.saidSideTwo = false
                try! startRecording() //TODO: FIX ALL TRY! TO CATCH PROPERLY
            }
        }
        else {
            if (studyMode == .answer) {
                saySideOne()
            }
            else if (studyMode == .noVoice){
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (t:Timer) in self.saySideOne() }
            }
            else {
                self.saidSideOne = false
                try! startRecording()
            }
        }
    }

}
