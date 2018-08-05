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
    var sideThreeName: String? = nil
    var managedObjectContext:NSManagedObjectContext?
    var currentSet:Set?
    var parentSetTVC:SetsTableViewController? //use this to perform segue to cardstvc upon click of "create" button
    
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var sideOneLangPicker: UIPickerView!
    @IBOutlet weak var sideTwoLangPicker: UIPickerView!
    @IBOutlet weak var sideOneNameField: UITextField!
    @IBOutlet weak var sideTwoNameField: UITextField!
    @IBOutlet weak var sideThreeInfoLabel: UILabel!
    
    var sideThreeInfoLabelText: String! {
        get {
            if sideThreeLangID != nil and side
        }
    }
    
    //TODO: CHECK FOR WHEN CRASHES WHEN CREATING SET, MAYBE WHEN I COME BACK CONTEXT IS NIL ?? BUT THAT IS CHECKED FOR...
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextBox.delegate = self
        titleTextBox.becomeFirstResponder()
        sideOneNameField.delegate = self
        sideTwoNameField.delegate = self
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
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addThirdSide" {
            if let sideThreevc = segue.destination as? SideThreeViewController {
                sideThreevc.parentVC = self
            }
        }
    }

}
