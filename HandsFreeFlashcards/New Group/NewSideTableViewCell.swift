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
    @IBOutlet weak var sideLangTextField: UITextField!
    @IBOutlet weak var removeSideButton: UIButton!
    
    var parentVC: NewSetViewController?
    var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sideNameTextField.delegate = self
        sideNameTextField.tag = 0
        sideNameTextField.addBottomBorder()
        sideLangTextField.delegate = self
        sideLangTextField.tag = 1
        sideLangTextField.addBottomBorder()
        // Initialization code
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
        if let lang = info.language {
            sideLangTextField.text = lang
        }
        else {
            sideLangTextField.text = ""
            sideLangTextField.placeholder = "Enter language here..."
        }
        if side > 2 {
            removeSideButton.isHidden = false
        }
        else {
            removeSideButton.isHidden = true
        }
    }
    @IBAction func removeSideClicked(_ sender: UIButton) {
        parentVC?.removeSide()
    }
}
extension NewSideTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if index == nil { return true }
        if textField.tag == 0 {
            parentVC?.addName(index: index!, name: textField.text ?? "")
        }
        else if textField.tag == 1 {
            parentVC?.addLanguage(index: index!, lang: textField.text ?? "")
        }
        return true
    }
    
}
