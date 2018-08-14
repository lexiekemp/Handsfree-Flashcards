//
//  SideThreeViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/22/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class SideThreeViewController: RootViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var parentVC: CreateSetViewController?
    var languageOptions = ["中文","Español","Français", "Deutsch","English","العربية"]
    var sideThreeLangID:String? = nil
    var sideThreeName: String? = nil
    
    @IBOutlet weak var sideThreeLangPicker: UIPickerView!
    @IBOutlet weak var sideThreeNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideThreeLangPicker.delegate = self
        sideThreeLangPicker.dataSource = self
        sideThreeNameField.delegate = self
        sideThreeLangPicker.showsSelectionIndicator = true
        sideThreeLangPicker.selectRow(0, inComponent: 0, animated: true)
        sideThreeLangID = parentVC?.getLangID(languageOptions[0])
        if parentVC?.sideThreeName != nil && parentVC?.sideThreeLangID != nil {
            sideThreeName = parentVC?.sideThreeName
            sideThreeLangID = parentVC?.sideThreeLangID
            sideThreeNameField.text = sideThreeName
            if sideThreeLangID != nil {
                if let langIDIndex = languageOptions.index(of: getLangName(sideThreeLangID!)){
                sideThreeLangPicker.selectRow(langIDIndex, inComponent: 0, animated: true)
                }
            }
        }
    }

    internal func getLangName(_ lang:String) -> String {
        if lang == "zh-Hans" {
            return "中文"
        }
        if lang == "es" {
            return "Español"
        }
        if lang == "fr" {
            return "Français"
        }
        if lang == "de" {
            return "Deutsch"
        }
        if lang == "ar-Arabic" {
            return "العربية"
        }
        return "English"
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addSide(_ sender: UIButton) {
        if sideThreeName == nil {
            errorAlert(message: "Please enter a name for this side")
            return
        }
        if sideThreeLangID == nil {
            errorAlert(message: "Please pick a language")
            return
        }
        parentVC?.sideThreeName = sideThreeName
        parentVC?.sideThreeLangID = sideThreeLangID
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func removeSide(_ sender: UIButton) {
        parentVC?.sideThreeName = nil
        parentVC?.sideThreeLangID = nil
        self.dismiss(animated: true, completion: nil)
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
        let sideThreeLang = languageOptions[pickerView.selectedRow(inComponent: component)]
        sideThreeLangID = parentVC?.getLangID(sideThreeLang)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sideThreeName = textField.text
        textField.resignFirstResponder()
        return true
    }


}