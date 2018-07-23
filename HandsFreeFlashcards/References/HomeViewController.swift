//
//  HomeViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 11/8/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import Speech

class HomeViewController: UIViewController, SFSpeechRecognizerDelegate {

    private let speechRecognizer = SFSpeechRecognizer(locale:Locale(identifier:"en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @IBOutlet weak var recognizeButton: UIButton!
    @IBOutlet weak var speechLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizeButton.isEnabled = false
        self.recognizeButton.setTitle("Recognition authorization no yet granted", for:.disabled)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization {
            authStatus in
            OperationQueue.main.addOperation {
                switch authStatus{
                case .authorized:
                    self.recognizeButton.isEnabled = true
                    self.recognizeButton.setTitle("Start",for:[])
                case .denied:
                    self.recognizeButton.isEnabled = false
                     self.recognizeButton.setTitle("Recognition authorization not granted", for:.disabled)
                case .restricted:
                    self.recognizeButton.isEnabled = false
                     self.recognizeButton.setTitle("Recognition restricted", for:.disabled)
                case .notDetermined:
                    self.recognizeButton.isEnabled = false
                     self.recognizeButton.setTitle("Recognition authorization no yet granted", for:.disabled)
                }
            }
        }
        
    }
    
    private func startRecording() throws {
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
            var isFinal = false
            if (result != nil) {
                self.speechLabel.text = result!.bestTranscription.formattedString
                isFinal = result!.isFinal
            }
            if (error != nil || isFinal) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recognizeButton.isEnabled = true
                self.recognizeButton.setTitle("Start",for:[])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        speechLabel.text = "Listening"
    }
    
    //MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recognizeButton.isEnabled = true
            recognizeButton.setTitle("Start",for:[])
        }
        else {
            recognizeButton.isEnabled = false
            recognizeButton.setTitle("Recognition Unavailable", for:.disabled)
        }
    }

    @IBAction func recognizeSpeech(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognizeButton.isEnabled = false
            recognizeButton.setTitle("Stopping", for: .disabled)
        }
        else {
            try! startRecording()
            recognizeButton.setTitle("Stop", for:[])
        }
    }

}
