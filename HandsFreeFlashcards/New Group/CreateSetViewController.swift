//
//  CreateSetViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/1/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class CreateSetViewController: RootViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var languageOptions = ["中文","Español","Français", "Deutsch","English","العربية"]
    var sideOneLangID = "en-US"
    var sideOneName = "Word"
    var sideTwoLangID = "en-US"
    var sideTwoName = "Definition"
    var sideThreeLangID:String? = nil
    var sideThreeName: String? = nil {
        didSet {
            if sideThreeName != nil {
                sideThreeInfoLabel.text = "Side Three: " + sideThreeName!
                sideThreeButton.setTitle("Edit third side", for: .normal)
                sideThreeButton.setTitle("Edit third side", for: .selected)
            }
            else {
                sideThreeInfoLabel.text = "Side Three: None"
                sideThreeButton.setTitle("Add third side", for: .normal)
                sideThreeButton.setTitle("Add third side", for: .selected)
            }
        }
    }
    var managedObjectContext:NSManagedObjectContext?
    var currentSet:Set?
    var parentSetTVC:SetsTableViewController? //use this to perform segue to cardstvc upon click of "create" button
    var editedSideOneName = false
    var editedSideTwoName = false
    
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var sideOneLangPicker: UIPickerView!
    @IBOutlet weak var sideTwoLangPicker: UIPickerView!
    @IBOutlet weak var sideOneNameField: UITextField!
    @IBOutlet weak var sideTwoNameField: UITextField!
    @IBOutlet weak var sideThreeInfoLabel: UILabel!
    @IBOutlet weak var sideThreeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
         self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        titleTextBox.delegate = self
        sideOneNameField.delegate = self
        sideTwoNameField.delegate = self
        sideOneNameField.tag = 1
        sideTwoNameField.tag = 2
        sideOneLangPicker.delegate = self
        sideTwoLangPicker.delegate = self
        sideOneLangPicker.dataSource = self
        sideTwoLangPicker.dataSource = self
        sideOneLangPicker.tag = 0
        sideTwoLangPicker.tag = 1
        sideOneLangPicker.showsSelectionIndicator = true
        sideTwoLangPicker.showsSelectionIndicator = true
        sideOneLangPicker.selectRow(0, inComponent: 0, animated: true)
        sideTwoLangPicker.selectRow(0, inComponent: 0, animated: true)
        sideOneLangID = getLangID(languageOptions[0])
        sideTwoLangID = getLangID(languageOptions[0])
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageOptions.count
    }
    
    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            let sideOneLang = languageOptions[pickerView.selectedRow(inComponent: component)]
            sideOneLangID = getLangID(sideOneLang)
        }
        else {
            let sideTwoLang = languageOptions[pickerView.selectedRow(inComponent: component)]
            sideTwoLangID = getLangID(sideTwoLang)
        }
    }
   
    @IBAction func createSet(_ sender: UIButton) {
        if managedObjectContext == nil {
            errorAlert(message: "Context is nil.")
            return
        }
        let setName = titleTextBox.text
        
        if setName == nil || setName!.isEmpty {
            errorAlert(message: "Please enter proper data.")
            return
        }
        currentSet = Set.addSet(setName: setName!, sideOneLangID: sideOneLangID, sideTwoLangID: sideTwoLangID, sideThreeLangID: sideThreeLangID, sideOneName: sideOneName, sideTwoName: sideTwoName, sideThreeName: sideThreeName, inManagedObjectContext: managedObjectContext!)
        if currentSet == nil {
            errorAlert(message: "currentSet is nil.")
        }
        else {
            if let sideOneInfo = SideInfo.addSideInfo(name: sideOneName, langID: sideOneLangID, index: 0, inManagedObjectContext: managedObjectContext!) {
                 currentSet?.addToSideInfo(sideOneInfo)
            }
            if let sideTwoInfo = SideInfo.addSideInfo(name: sideTwoName, langID: sideTwoLangID, index: 1, inManagedObjectContext: managedObjectContext!) {
                currentSet?.addToSideInfo(sideTwoInfo)
            }
            if sideThreeName != nil && sideThreeLangID != nil {
                if let sideThreeInfo = SideInfo.addSideInfo(name: sideThreeName!, langID: sideThreeLangID!, index: 2, inManagedObjectContext: managedObjectContext!) {
                    currentSet?.addToSideInfo(sideThreeInfo)
                }
            }
        
            self.dismiss(animated: true) { //TODO: NEED WEAKSELF?
                self.parentSetTVC?.selectedSets.insert(self.currentSet!, at: 0)
                self.parentSetTVC?.setFirstResponder = true
                self.parentSetTVC?.performSegue(withIdentifier: "showCards", sender: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    internal func getLangID(_ lang:String) -> String {
        if lang == "中文" {
            return "zh-Hans"
        }
        if lang == "Español" {
            return "es"
        }
        if lang == "Français" {
            return "fr"
        }
        if lang == "Deutsch" {
            return "de"
        }
        if lang == "العربية" {
            return "ar-Arabic"
        }
        return "en-US"
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 1, textField.text != nil {
            self.sideOneName = textField.text!
        }
        else if textField.tag == 2, textField.text != nil {
            self.sideTwoName = textField.text!
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 && editedSideOneName == false {
            textField.text = ""
            editedSideOneName = true
        }
        else if textField.tag == 2 { //sideTwoNameField
            moveTextField(textField, moveDistance: -50, up: true)
            if editedSideTwoName == false {
                textField.text = ""
                editedSideTwoName = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2 { //sideTwoNameField
            moveTextField(textField, moveDistance: -50, up: false)
        }
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addThirdSide" {
            if let sideThreevc = segue.destination as? SideThreeViewController {
                sideThreevc.parentVC = self
            }
        }
    }

}
