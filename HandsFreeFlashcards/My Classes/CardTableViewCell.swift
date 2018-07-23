//
//  CardTableViewCell.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/3/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    

    //@IBOutlet weak var wordLabel: UILabel!
    //@IBOutlet weak var defLabel: UILabel!
    
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var defTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wordTextField.borderStyle = UITextBorderStyle.none
        defTextField.borderStyle = UITextBorderStyle.none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
