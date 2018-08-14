//
//  SideChoiceViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class SideChoiceViewController: RootViewController, UITableViewDelegate, UITableViewDataSource {

    var studySets:[Set]?
    var sideChoices = [String]()
    var studyMode:Mode = .answer
    var firstChoiceIndex = 1
    var secondChoiceIndex = 2
    var thirdChoiceIndex:Int?
    var repeatIncorrect = false
    
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var secondTableView: UITableView!
    @IBOutlet weak var thirdTableView: UITableView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firstArrowButton: UIButton!
    @IBOutlet weak var secondArrowButton: UIButton!
    @IBOutlet weak var thirdArrowButton: UIButton!
    @IBOutlet weak var repeatIncorrectSwitch: UISwitch!
    @IBOutlet weak var repeatIncorrectLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTableView.delegate = self
        secondTableView.delegate = self
        thirdTableView.delegate = self
        firstTableView.dataSource = self
        secondTableView.dataSource = self
        thirdTableView.dataSource = self
        firstTableView.tag = 1
        secondTableView.tag = 2
        thirdTableView.tag = 3
        firstTableView.isHidden = true
        secondTableView.isHidden = true
        thirdTableView.isHidden = true
        
        if studySets != nil {
            if studySets!.count == 1 {
                sideChoices.append(studySets![0].sideOneName!)
                sideChoices.append(studySets![0].sideTwoName!)
                if studySets![0].sideThreeName != nil{
                    sideChoices.append(studySets![0].sideThreeName!)
                    if studyMode != .manual {
                        thirdButton.isHidden = true
                        thirdLabel.isHidden = true
                        thirdArrowButton.isHidden = true
                    }
                }
            }
            else {
                firstButton.isHidden = true
                firstLabel.isHidden = true
                firstArrowButton.isHidden = true
                secondButton.isHidden = true
                secondLabel.isHidden = true
                secondArrowButton.isHidden = true
                thirdButton.isHidden = true
                thirdLabel.isHidden = true
                thirdArrowButton.isHidden = true
                chooseLabel.isHidden = true
            }
        }
        else {
            errorAlert(message: "No set chosen. Please try again.")
            return;
        }

        if !(studyMode == .answer || studyMode == .answerAndRep) {
            repeatIncorrectSwitch.isHidden = true
            repeatIncorrectLabel.isHidden = true
        }
    }
    
    @IBAction func selectFirst(_ sender: UIButton) {
        firstTableView.isHidden = !firstTableView.isHidden
    }
    @IBAction func selectSecond(_ sender: UIButton) {
        secondTableView.isHidden = !secondTableView.isHidden
    }
    @IBAction func selectThird(_ sender: UIButton) {
        thirdTableView.isHidden = !thirdTableView.isHidden
    }
    @IBAction func toggleRepeat(_ sender: UISwitch) {
        repeatIncorrect = !repeatIncorrect
    }
    @IBAction func gotToStudy(_ sender: UIButton) {
        if studyMode == .manual {
            self.performSegue(withIdentifier: "manualStudy", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "voiceStudy", sender: nil)
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideOptCell", for: indexPath)
        if indexPath.row < sideChoices.count {
            cell.textLabel?.text = sideChoices[indexPath.row]
        }
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            if indexPath.row < sideChoices.count {
                firstChoiceIndex = indexPath.row + 1 //side number
                firstButton.setTitle(sideChoices[indexPath.row], for: .normal)
                firstButton.setTitle(sideChoices[indexPath.row], for: .selected)
            }
        }
        else if tableView.tag == 2 { //termsTableView
            if indexPath.row < sideChoices.count {
                secondChoiceIndex = indexPath.row + 1
                secondButton.setTitle(sideChoices[indexPath.row], for: .normal)
                secondButton.setTitle(sideChoices[indexPath.row], for: .selected)
            }
        }
        else if tableView.tag == 3 { //termsTableView
            if indexPath.row < sideChoices.count {
                thirdChoiceIndex = indexPath.row + 1
                thirdButton.setTitle(sideChoices[indexPath.row], for: .normal)
                thirdButton.setTitle(sideChoices[indexPath.row], for: .selected)
            }
        }
        tableView.isHidden = true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manualStudy" {
            if let manualStudyVC = segue.destination as? ManualStudyViewController {
                manualStudyVC.studySets = studySets
                manualStudyVC.firstChoiceIndex = firstChoiceIndex
                manualStudyVC.secondChoiceIndex = secondChoiceIndex
                if thirdChoiceIndex != nil {
                    manualStudyVC.thirdChoiceIndex = thirdChoiceIndex!
                }
            }
        }
        else if segue.identifier == "voiceStudy" {
            if let studyVC = segue.destination as? StudyViewController {
                studyVC.studySets = studySets
                studyVC.studyMode = studyMode
                studyVC.firstChoiceIndex = firstChoiceIndex
                studyVC.secondChoiceIndex = secondChoiceIndex
            }
        }
    }
    

}