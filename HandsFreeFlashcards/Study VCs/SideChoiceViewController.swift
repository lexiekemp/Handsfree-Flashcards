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

    var set:Set?
    var sideChoices: [String]?
    
    var firstChoiceIndex:Int?
    var secondChoiceIndex:Int?
    var thirdChoiceIndex:Int?
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var secondTableView: UITableView!
    @IBOutlet weak var thirdTableView: UITableView!
    @IBOutlet weak var thirdLabel: UILabel!
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
        
        if set != nil {
            if (set!.sideOneName != nil) {
                sideChoices.append(set!.sideOneName)
            }
            if
            sideChoices.append(set!.sideTwoName)
            sideChoices.append(set!.sideThreeName)
        }
        else {
            errorAlert(message: "No set chosen. Please try again.")
            return;
        }
        firstChoiceIndex = 1
        secondChoiceIndex = 2
        
        //if side three and correct mode
        thirdChoice = sideChoices![2]
        
        //if no side three (else)
        thirdButton.isHidden = true
        thirdLabel.isHidden = true
        thirdArrowButton.isHidden = true
        
        //if mode without answer
        repeatIncorrectSwitch.isHidden = true
        repeatIncorrectLabel.isHidden = true
        
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
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sideChoices != nil {
            return sideChoices!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideOptCell", for: indexPath)
        if sideChoices != nil {
            cell.textLabel?.text = sideChoices![indexPath.row]
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
        if sideChoices != nil {
            if tableView.tag == 1 {
                firstChoiceIndex = indexPath.row + 1 //side number
                firstButton.setTitle(sideChoices![indexPath.row], for: .normal)
                firstButton.setTitle(sideChoices![indexPath.row], for: .selected)
            }
            else if tableView.tag == 2 { //termsTableView
                secondChoiceIndex = indexPath.row + 1
                secondButton.setTitle(sideChoices![indexPath.row], for: .normal)
                secondButton.setTitle(sideChoices![indexPath.row], for: .selected)
            }
            else if tableView.tag == 3 { //termsTableView
                thirdChoiceIndex = indexPath.row + 1
                thirdButton.setTitle(sideChoices![indexPath.row], for: .normal)
                thirdButton.setTitle(sideChoices![indexPath.row], for: .selected)
                
            }
        }
        else {
            errorAlert(message: "An error occurred. Please try again.")
        }
        tableView.isHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
