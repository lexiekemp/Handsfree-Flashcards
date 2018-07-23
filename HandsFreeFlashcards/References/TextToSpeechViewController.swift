//
//  TextToSpeechViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 11/10/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import AVFoundation

class TextToSpeechViewController: UIViewController {

    @IBOutlet weak var readMeLabel: UILabel!
    
    let synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    @IBAction func readText(_ sender: UIButton) {
        utterance = AVSpeechUtterance(string: readMeLabel.text!)
        utterance.voice = AVSpeechSynthesisVoice(language:"en-US")
        utterance.rate = 0.4
        synth.speak(utterance)
    }
    

}
