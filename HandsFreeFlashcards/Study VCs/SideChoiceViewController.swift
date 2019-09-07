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
    var sortByIndex: Int?
    
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
    @IBOutlet weak var sortByLabel: UILabel!
    @IBOutlet weak var sortByFirstButton: UIButton!
    @IBOutlet weak var sortBySecondButton: UIButton!
    @IBOutlet weak var sortByThirdButton: UIButton!
    @IBOutlet weak var sortByShuffleButton: UIButton!
    
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
                firstTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                self.tableView(firstTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                sideChoices.append(studySets![0].sideTwoName!)
                secondTableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
                self.tableView(secondTableView, didSelectRowAt: IndexPath(row: 1, section: 0))
                if studySets![0].sideThreeName != nil{
                    sideChoices.append(studySets![0].sideThreeName!)
                    thirdTableView.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
                    self.tableView(thirdTableView, didSelectRowAt: IndexPath(row: 2, section: 0))
                    if studyMode != .manual {
                        thirdButton.isHidden = true
                        thirdLabel.isHidden = true
                        thirdArrowButton.isHidden = true
                    }
                }
                else {
                    thirdButton.isHidden = true
                    thirdLabel.isHidden = true
                    thirdArrowButton.isHidden = true
                    sortByThirdButton.isHidden = true
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
                if studySets!.count  > 1 {
                    var threeSides = true
                    for set in studySets! {
                        if set.sideThreeName == nil {
                            sortByThirdButton.isHidden = true //only allow to sort by third side if all desks selected have three side
                            threeSides = false
                            break
                        }
                    }
                    if threeSides {
                        thirdChoiceIndex = 3
                    }
                }
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
        if studyMode != .manual {
            sortByFirstButton.isHidden = true
            sortBySecondButton.isHidden = true
            sortByThirdButton.isHidden = true
            sortByShuffleButton.isHidden = true
            sortByLabel.isHidden = true
            if studySets!.count  > 1 { //go straight to start
                self.performSegue(withIdentifier: "voiceStudy", sender: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if studySets != nil, studySets!.count == 1 {
            firstTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            secondTableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
             if studySets![0].sideThreeName != nil {
                thirdTableView.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    @IBAction func sortByFirst(_ sender: UIButton) {
        sortByIndex = 1
        sortByLabel.text = "Sort by: first side"
    }
    @IBAction func sortBySecond(_ sender: UIButton) {
        sortByIndex = 2
        sortByLabel.text = "Sort by: second side"
    }
    @IBAction func sortByThird(_ sender: UIButton) {
        sortByIndex = 3
        sortByLabel.text = "Sort by: third side"
    }
    @IBAction func sortByShuffle(_ sender: UIButton) {
        sortByIndex = nil
        sortByLabel.text = "Sort by: shuffle"
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
        if tableView.tag == 3 {
            return sideChoices.count + 1
        }
        return sideChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideOptCell", for: indexPath)
        if indexPath.row < sideChoices.count {
            cell.textLabel?.text = sideChoices[indexPath.row]
        }
        else {
            cell.textLabel?.text = "None"
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
            else {
                thirdChoiceIndex = nil
                thirdButton.setTitle("None", for: .normal)
                thirdButton.setTitle("None", for: .selected)
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
                switch sortByIndex {
                case 1:
                    manualStudyVC.sortChoiceIndex = firstChoiceIndex - 1
                case 2:
                    manualStudyVC.sortChoiceIndex = secondChoiceIndex - 1
                case 3:
                    if thirdChoiceIndex != nil {
                        manualStudyVC.sortChoiceIndex = thirdChoiceIndex! - 1
                    }
                default:
                    manualStudyVC.sortChoiceIndex = nil
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
