//
//  StudyModeViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/5/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

public enum Mode {
    case answer, answerAndRep, rep, noVoice, manual
}

class StudyModeViewController: UIViewController {

    var studySets: [Set]?
    var studyMode: Mode = .answer
    var repeatIncorrect = false
    var defFirst = false
    
    @IBAction func answer(_ sender: UIButton) {
        studyMode = .answer
        self.performSegue(withIdentifier: "goToSideChoices", sender: nil)
    }
    
    @IBAction func answerAndRep(_ sender: UIButton) {
        studyMode = .answerAndRep
        self.performSegue(withIdentifier: "goToSideChoices", sender: nil)
    }
    
    @IBAction func rep(_ sender: UIButton) {
        studyMode = .rep
        self.performSegue(withIdentifier: "goToSideChoices", sender: nil)
    }
    @IBAction func noVoice(_ sender: UIButton) {
        studyMode = .noVoice
        self.performSegue(withIdentifier: "goToSideChoices", sender: nil)
    }
    @IBAction func manual(_ sender: UIButton) {
        studyMode = .manual
        self.performSegue(withIdentifier: "goToSideChoices", sender: nil)
    }
    @IBAction func toggleRepeat(_ sender: UISwitch) {
        repeatIncorrect = !repeatIncorrect
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSideChoices" {
            if let sideChoiceVC = segue.destination as? SideChoiceViewController {
                if studySets != nil {
                    sideChoiceVC.studySets = studySets
                }
                sideChoiceVC.studyMode = studyMode
            }
        }
    }
    

}
