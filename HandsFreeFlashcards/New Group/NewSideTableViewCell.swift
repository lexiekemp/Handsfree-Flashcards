//
//  NewSideTableViewCell.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/26/19.
//  Copyright © 2019 Lexie Kemp. All rights reserved.
//

import UIKit
class NewSideTableViewCell: UITableViewCell {

    @IBOutlet weak var sideLabel: UILabel!
    @IBOutlet weak var sideNameLabel: UILabel!
    @IBOutlet weak var sideNameTextField: UITextField!
   // @IBOutlet weak var sideLangTextField: UITextField!
    @IBOutlet weak var removeSideButton: UIButton!
    
    var parentVC: NewSetViewController?
    var index: Int?
    var suggestedLangs: [String] = ["English"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sideNameTextField.delegate = self
        sideNameTextField.tag = 0
        sideNameTextField.addBottomBorder()
//        sideLangTextField.delegate = self
//        sideLangTextField.tag = 1
//        sideLangTextField.addBottomBorder()
        
//        sideLangTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

    }
    func inflateCell(parent: NewSetViewController, side: Int, info: CellSideInfo) {
        parentVC = parent
        index = side - 1
        sideLabel.text = "Side " + side.numToWord()
        sideNameLabel.text = "Name for Side " + side.numToWord()
        if let name = info.name {
            sideNameTextField.text = name
        }
        else {
            sideNameTextField.text = ""
            sideNameTextField.placeholder = "Enter name here..."
        }
//        if let lang = info.language {
//            sideLangTextField.text = lang
//        }
//        else {
//            sideLangTextField.text = ""
//            sideLangTextField.placeholder = "Enter language here..."
//        }
        if side > 2 {
            removeSideButton.isHidden = false
        }
        else {
            removeSideButton.isHidden = true
        }
    }
    @IBAction func langButtonClicked(_ sender: UIButton) {
        parentVC?.goToLangPicker(index: index)
    }
    @IBAction func removeSideClicked(_ sender: UIButton) {
        parentVC?.removeSide()
    }
}
extension NewSideTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if index == nil { return true }
        parentVC?.addName(index: index!, name: textField.text ?? "")
//        if textField.tag == 0 {
//            parentVC?.addName(index: index!, name: textField.text ?? "")
//        }
//        else if textField.tag == 1 {
//            if langCodeDict[(textField.text ?? "")] == nil {
//                parentVC?.errorAlert(message: "Please enter a valid language")
//            }
//            parentVC?.addLanguage(index: index!, lang: textField.text ?? "")
//        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if index != (parentVC?.sideCount ?? 0) - 2 { return true }
        let _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.parentVC?.view.frame.origin.y -= (self?.parentVC?.keyboardHeight ?? 150)
        }
        return true
    }
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        guard let text = textField.text else { return }
//        if text == "" { return }
//        // let results = dict.flatMap { (key, value) in key.lowercased().contains("o") ? value : nil }
//        parentVC?.view.bringSubview(toFront: langTableView)
//       // langTableView.isHidden = false
//    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.parentVC?.view.frame.origin.y = 0
        return true
    }
}
//extension NewSideTableViewCell: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return suggestedLangs.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "langCell") else {
//            fatalError("langCell is not dequeueable")
//        }
//        cell.textLabel?.text = suggestedLangs[indexPath.row]
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        sideLangTextField.text = suggestedLangs[indexPath.row]
//        langTableView.isHidden = true
//    }
//
//}
