//
//  SetTableViewCell.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/3/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var setTitleTextField: UITextField!
    @IBOutlet weak var goToCardsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleTextField.borderStyle = UITextBorderStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
