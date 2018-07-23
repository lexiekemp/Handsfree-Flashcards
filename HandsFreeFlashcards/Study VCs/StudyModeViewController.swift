//
//  StudyModeViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/5/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class StudyModeViewController: UIViewController {

    var studySets: [Set]?
    var studyMode: Mode = .answer
    var repeatIncorrect = false
    var defFirst = false
    
    @IBAction func answer(_ sender: UIButton) {
        studyMode = .answer
        self.performSegue(withIdentifier: "study", sender: nil)
    }
    
    @IBAction func answerAndRep(_ sender: UIButton) {
        studyMode = .answerAndRep
        self.performSegue(withIdentifier: "study", sender: nil)
    }
    
    @IBAction func rep(_ sender: UIButton) {
        studyMode = .rep
        self.performSegue(withIdentifier: "study", sender: nil)
    }
    @IBAction func noVoice(_ sender: UIButton) {
        studyMode = .noVoice
        self.performSegue(withIdentifier: "study", sender: nil)
    }
    @IBAction func toggleRepeat(_ sender: UISwitch) {
        repeatIncorrect = !repeatIncorrect
    }
    @IBAction func toggleDefFirst(_ sender: UISwitch) {
        defFirst = !defFirst
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "study" {
            if let studyvc = segue.destination as? StudyViewController {
                if studySets != nil {
                    studyvc.studySets = studySets
                }
                studyvc.studyMode = studyMode
                studyvc.repeatIncorrect = repeatIncorrect
                studyvc.defFirst = defFirst
            }
        }
    }
    

}
