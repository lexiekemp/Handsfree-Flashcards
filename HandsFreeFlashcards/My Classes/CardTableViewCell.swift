//
//  CardTableViewCell.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/3/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardCellView: UIView!
    @IBOutlet weak var sideOneTextField: UITextField!
    @IBOutlet weak var sideTwoTextField: UITextField!
    @IBOutlet weak var sideThreeTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sideOneTextField.borderStyle = UITextBorderStyle.none
        sideTwoTextField.borderStyle = UITextBorderStyle.none
        sideThreeTextField.borderStyle = UITextBorderStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
