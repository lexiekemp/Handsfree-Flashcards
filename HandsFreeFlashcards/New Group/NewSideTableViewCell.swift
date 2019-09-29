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
    @IBOutlet weak var sideLangButton: UIButton!
    // @IBOutlet weak var sideLangTextField: UITextField!
    @IBOutlet weak var removeSideButton: UIButton!
    
    var parentVC: NewSetViewController?
    var index: Int?
    var suggestedLangs: [String] = ["English"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sideNameTextField.delegate = self
        sideNameTextField.addBottomBorder()
        sideLangButton.addBottomBorder()
    }
    func inflateCell(parent: NewSetViewController, side: Int, info: CellSideInfo) {
        parentVC = parent
        index = side - 1
        sideLabel.text = "Side " + side.numToWord()
        sideNameLabel.text = "Name for side " + side.numToWord()
        if let name = info.name {
            sideNameTextField.text = name
        }
        else {
            sideNameTextField.text = ""
            sideNameTextField.placeholder = "Enter name here..."
        }
        if let lang = info.language {
            sideLangButton.setTitle(lang, for: .normal)
        }
        else {
            sideLangButton.setTitle("Choose a language...", for: .normal)
        }
        
        if side > 2 {
            removeSideButton.isHidden = false
        }
        else {
            removeSideButton.isHidden = true
        }
    }
    @IBAction func langButtonClicked(_ sender: UIButton) {
        guard let i = index else { return }
        sideNameTextField.resignFirstResponder()
        parentVC?.addName(index: i, name: sideNameTextField.text ?? "")
        parentVC?.goToLangPicker(index: i)
    }
    @IBAction func removeSideClicked(_ sender: UIButton) {
        parentVC?.removeSide()
    }
}
extension NewSideTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let i = index else { return true }
        parentVC?.addName(index: i, name: textField.text ?? "")
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if index != (parentVC?.cellSideInfo.count ?? 0) - 1 { return true }
        let _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
            self?.parentVC?.view.frame.origin.y -= (self?.parentVC?.keyboardHeight ?? 150)
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.parentVC?.view.frame.origin.y = 0
        return true
    }
}
