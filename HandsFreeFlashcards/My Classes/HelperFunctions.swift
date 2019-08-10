//
//  HelperFunctions.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 8/2/19.
//  Copyright © 2019 Lexie Kemp. All rights reserved.
//

import Foundation
import UIKit
extension Int {
    func numToWord() -> String {
        let numberValue = NSNumber(value: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: numberValue)!
    }
}
extension UITextField {
    func addBottomBorder()  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 2, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.gray.cgColor // background color
        self.borderStyle = UITextBorderStyle.none // border style
        self.layer.addSublayer(bottomLine)
    }
}
extension UIButton {
    func addBottomBorder()  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.gray.cgColor // background color
        self.layer.addSublayer(bottomLine)
    }
}
extension UIView {
    func addShadow(scale: Bool = true, radius: CGFloat = 1.0) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

