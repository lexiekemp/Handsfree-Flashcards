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
    //TODO: have cancel and create buttons
    var languageOptions = ["中文","Español","Français", "Deutsch","English","العربية"]
    var wordLangID = "en-US"
    var defLangID = "en-US"
    var managedObjectContext:NSManagedObjectContext?
    var currentSet:Set?
    var parentSetTVC:SetsTableViewController? //use this to perform segue to cardstvc upon click of "create" button
    
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var wordLangPicker: UIPickerView!
    @IBOutlet weak var defLangPicker: UIPickerView!
    
    //TODO: CHECK FOR WHEN CRASHES WHEN CREATING SET, MAYBE WHEN I COME BACK CONTEXT IS NIL ?? BUT THAT IS CHECKED FOR...
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextBox.delegate = self
        titleTextBox.becomeFirstResponder()
        wordLangPicker.delegate = self
        defLangPicker.delegate = self
        wordLangPicker.dataSource = self
        defLangPicker.dataSource = self
        wordLangPicker.tag = 0
        defLangPicker.tag = 1
        wordLangPicker.showsSelectionIndicator = true
        defLangPicker.showsSelectionIndicator = true
        wordLangPicker.selectRow(0, inComponent: 0, animated: true)
        wordLangID = getLangID(languageOptions[0])
        defLangID = getLangID(languageOptions[0])
        defLangPicker.selectRow(0, inComponent: 0, animated: true)
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
            let wordLang = languageOptions[pickerView.selectedRow(inComponent: component)]
            wordLangID = getLangID(wordLang)
        }
        else {
            let defLang = languageOptions[pickerView.selectedRow(inComponent: component)]
            defLangID = getLangID(defLang)
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
        currentSet = Set.addSet(name: setName!, wordLangID: wordLangID, defLangID: defLangID, inManagedObjectContext: managedObjectContext!)
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
    private func getLangID(_ lang:String) -> String {
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

}
