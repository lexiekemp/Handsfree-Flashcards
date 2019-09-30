//
//  NewSetViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/26/19.
//  Copyright © 2019 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

struct CellSideInfo {
    var name: String?
    var language: String?
}
class NewSetViewController: RootViewController {

    @IBOutlet weak var setTitleView: UIView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setTitleTextField: UITextField!
    @IBOutlet weak var sidesTable: UITableView!
    @IBOutlet weak var createSetButton: UIButton!
    
    var cellSideInfo: [CellSideInfo] = []
    var managedObjectContext:NSManagedObjectContext?
    var currentSet:Set?
    var parentSetTVC:SetsTableViewController? //use this to perform segue to cardstvc upon click of "create" button
    var sideCount = 3
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        setTitleTextField.delegate = self
        setTitleTextField.addBottomBorder()
        setTitleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        sidesTable.dataSource = self
        sidesTable.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        let defaultSideInfo = CellSideInfo(name: nil, language: nil)
        self.cellSideInfo = Array(repeating: defaultSideInfo, count: 2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.setTitleView.addGestureRecognizer(tap)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sidesTable.reloadData()
        _ = isValidInput()
    }
    @IBAction func createSetClicked(_ sender: UIButton) {
        if let err = isValidInput() {
            errorAlert(message: err)
            return
        }
        if managedObjectContext == nil {
            errorAlert(message: "Context is nil.")
            return
        }
        let setName = setTitleTextField.text
        if setName == nil || setName!.isEmpty {
            errorAlert(message: "Please enter proper data.")
            return
        }
        if cellSideInfo.count < 2 {
            errorAlert(message: "Error, please try again.")
            return
        }
        let langOne = cellSideInfo[0].language ?? ""
        let langTwo = cellSideInfo[1].language ?? ""
        var langIdThree:String?
        let nameOne = cellSideInfo[0].name ?? ""
        let nameTwo = cellSideInfo[1].name ?? ""
        var nameThree:String?
        
        guard let langIdOne = langCodeDict[langOne], let langIdTwo = langCodeDict[langTwo] else {
            errorAlert(message: "Please enter valid languages")
            return
        }
        if nameOne.isEmpty || nameTwo.isEmpty {
            errorAlert(message: "Please enter valid names")
            return
        }
        if cellSideInfo.count == 2 {
            currentSet = Set.addSet(setName: setName!, sideOneLangID: langIdOne, sideTwoLangID: langIdTwo, sideThreeLangID: nil, sideOneName: nameOne, sideTwoName: nameTwo, sideThreeName: nil, inManagedObjectContext: managedObjectContext!)
        }
        else {
            let langThree = cellSideInfo[2].language ?? ""
            nameThree = cellSideInfo[2].name ?? ""
            
            langIdThree = langCodeDict[langThree]
            if langIdThree == nil {
                errorAlert(message: "Please entere valid languages")
                return
            }
            if nameThree?.isEmpty ?? true {
                errorAlert(message: "Please enter valid names")
                return
            }
            currentSet = Set.addSet(setName: setName!, sideOneLangID: langIdOne, sideTwoLangID: langIdTwo, sideThreeLangID: langIdThree, sideOneName: nameOne, sideTwoName: nameTwo, sideThreeName: nameThree, inManagedObjectContext: managedObjectContext!)
        }
        if currentSet == nil {
            errorAlert(message: "currentSet is nil.")
            return
        }
        if let sideOneInfo = SideInfo.addSideInfo(name: nameOne, langID: langIdOne, index: 0, inManagedObjectContext: managedObjectContext!) {
            currentSet?.addToSideInfo(sideOneInfo)
        }
        if let sideTwoInfo = SideInfo.addSideInfo(name: nameTwo, langID: langIdTwo, index: 1, inManagedObjectContext: managedObjectContext!) {
            currentSet?.addToSideInfo(sideTwoInfo)
        }
        if nameThree != nil && langIdThree != nil {
            if let sideThreeInfo = SideInfo.addSideInfo(name: nameThree!, langID: langIdThree!, index: 2, inManagedObjectContext: managedObjectContext!) {
                currentSet?.addToSideInfo(sideThreeInfo)
            }
        }
        navigationController?.popViewController(animated: true)
        self.parentSetTVC?.selectedSets.insert(self.currentSet!, at: 0)
        self.parentSetTVC?.setFirstResponder = true
        self.parentSetTVC?.performSegue(withIdentifier: "showCards", sender: nil)
        
    }
    @IBAction func cancelClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    func goToLangPicker(index: Int) {
        self.performSegue(withIdentifier: "goToLangPicker", sender: index)
    }
    //return error or nil if valid
    func isValidInput() -> String? {
        var error: String?
        let setName = setTitleTextField.text
        if setName == nil || setName!.isEmpty {
            error = "Please enter a valid set name"
        }
        else {
            for i in 0..<cellSideInfo.count {
                let name = cellSideInfo[i].name ?? ""
                let lang = cellSideInfo[i].language ?? ""
                
                if name.isEmpty {
                    error = "Please enter a valid name for side " + (i+1).numToWord()
                    break
                }
                if langCodeDict[lang] == nil {
                    error = "Please enter a valid language for side " + (i+1).numToWord()
                    break
                }
            }
        }
        (error == nil) ? setCreateSetButtonAqua():setCreateSetButtonGrey()
        return error
    }
    func setCreateSetButtonAqua() {
        createSetButton.backgroundColor = UIColor(red:0.10, green:0.73, blue:0.76, alpha:1.0)
    }
    func setCreateSetButtonGrey() {
        createSetButton.backgroundColor = UIColor(red:0.68, green:0.71, blue:0.71, alpha:1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLangPicker" {
            if let langPickerVC = segue.destination as? LangPickerViewController, let index = sender as? Int {
                langPickerVC.newSetVC = self
                langPickerVC.sideIndex = index
            }
        }
    }
}

extension NewSetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < cellSideInfo.count {
            return 145
        }
        else {
            return 44
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cellSideInfo.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newSideCell", for: indexPath) as! NewSideTableViewCell
            cell.selectionStyle = .none
            cell.inflateCell(parent: self, side: indexPath.row + 1, info: cellSideInfo[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "addSideCell", for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellSideInfo.count {
            //tapped +add a side button
            let defaultSideInfo = CellSideInfo(name: nil, language: nil)
            cellSideInfo.append(defaultSideInfo)
            tableView.reloadData()
        }
        setTitleTextField.resignFirstResponder()
    }
    func removeSide() {
        _ = cellSideInfo.popLast()
        sidesTable.reloadData()
    }
    func addName(index: Int, name: String) {
        if index >= cellSideInfo.count {
            errorAlert(message: "Error, please try again")
            return
        }
        cellSideInfo[index].name = name
        _ = isValidInput()
        return
    }
    func addLanguage(index: Int, lang: String) {
        if index >= cellSideInfo.count {
            errorAlert(message: "Error, please try again")
            return
        }
        cellSideInfo[index].language = lang
        _ = isValidInput()
    }

}
extension NewSetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setTitleLabel.text = textField.text
        textField.resignFirstResponder()
        _ = isValidInput()
        return true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            setTitleLabel.text = text
        }
    }
    func textFieldUpdate(_ textField: UITextField) {
        if let text = textField.text {
            setTitleLabel.text = text
        }
    }
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        setTitleTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
}

