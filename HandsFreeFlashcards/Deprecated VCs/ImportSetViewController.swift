//
//  ImportSetViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 11/10/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class ImportSetViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var languageOptions = ["中文","Español","Français", "Deutsch","English","العربية"]
    var wordLangID = "en-US"
    var defLangID = "en-US"
    var managedObjectContext:NSManagedObjectContext?
    var currentSet:Set?
    
    @IBOutlet weak var setTextBox: UITextField!
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var wordLangPicker: UIPickerView!
    @IBOutlet weak var defLangPicker: UIPickerView!
    
    //TODO: CHECK FOR WHEN CRASHES WHEN CREATING SET, MAYBE WHEN I COME BACK CONTEXT IS NIL ?? BUT THAT IS CHECKED FOR...
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextBox.delegate = self
        titleTextBox.delegate = self
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
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
            }
        })
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
    private func checkSyntax(_ setToParse: String) -> Bool {
        var needChar = true
        var readingWord = true
        var needComma = false
        var semiColonOK = false
        for c in setToParse {
            if c == "," {
                if (!needComma) {
                    return false
                }
                else {
                    readingWord = false
                    needComma = false
                    needChar = true
                }
            }
            else if c == ";" {
                if (!semiColonOK) {
                    return false
                }
                else {
                    readingWord = true
                    semiColonOK = false
                }
            }
            else { //part of word or def
                if (readingWord) {
                    needComma = true
                    needChar = false
                }
                else {
                    semiColonOK = true
                    needChar = false
                }
            }
        }
        if (needComma || needChar) {
            return false
        }
        return true
    }
    private func parseText() -> Bool {
        if managedObjectContext == nil {
            return false
        }
        if let setToParse = setTextBox.text {
            if !checkSyntax(setToParse) {
                errorAlert(message: "Please enter correct syntax for set")
                return true
            }
            var currWord = ""
            var currDef = ""
            var readingWord = true
            for c in setToParse {
                if (c == ",") {
                    readingWord = false
                }
                else if (c == ";") {
                    readingWord = true
                    _ = Card.addCard(word: currWord, definition: currDef, set: currentSet!, inManagedObjectContext: managedObjectContext!)
                    currWord = ""
                    currDef = ""
                }
                else {
                    if (readingWord) {
                        currWord+=String(c)
                    }
                    else {
                        currDef+=String(c)
                    }
                }
            }
            if !currWord.isEmpty && !currDef.isEmpty {
                _ = Card.addCard(word: currWord, definition: currDef, set: currentSet!, inManagedObjectContext: managedObjectContext!)
            }
        }
        return true
    }
    private func errorAlert(message: String) {
        let alertController = UIAlertController(title:"Error", message: message, preferredStyle:.alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated:true, completion:nil)
    }

    @IBAction func createSet(_ sender: UIButton) {
        if managedObjectContext == nil {
            errorAlert(message: "Context is nil.")
            return
        }
        let setName = titleTextBox.text
        let cards = setTextBox.text
        
        if setName == nil || cards == nil || setName!.isEmpty {
            errorAlert(message: "Please enter proper data.")
            return
        }
        currentSet = Set.addSet(name: setName!, wordLangID: wordLangID, defLangID: defLangID, inManagedObjectContext: managedObjectContext!)
        if currentSet != nil {
            if !parseText() {
                errorAlert(message: "Cards could not be saved")
                return
            }
        }
        else {
            errorAlert(message: "currentSet is nil.")
            return
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    */
    

}
