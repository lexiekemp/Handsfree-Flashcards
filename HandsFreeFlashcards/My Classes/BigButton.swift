//
//  BigButton.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/1/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class BigButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
        self.tintColor = UIColor.black
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor(red:0.07, green:0.64, blue:0.67, alpha:1.0).cgColor //aqua
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.titleEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        self.titleLabel?.textAlignment = .center
        
        
        */
        //round corners
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        self.layer.borderWidth = 2.0
        self.titleEdgeInsets = UIEdgeInsets(top: 10, left:10, bottom: 10, right: 10)
        
        //set color
        let aquaColor = UIColor(red:0.07, green:0.64, blue:0.67, alpha:1.0)
        self.setTitleColor(aquaColor, for: .normal)
        self.layer.borderColor = aquaColor.cgColor
    }
}
