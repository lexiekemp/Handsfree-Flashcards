//
//  ModeInfoViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/18/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit

class ModeInfoViewController: UIViewController {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outerView.layer.cornerRadius = 15
        outerView.layer.masksToBounds = true
        
        shadowView.layer.cornerRadius = 15
        shadowView.layer.masksToBounds = true
        let shadowColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha: 1.0)
        shadowView.backgroundColor = shadowColor
        
        let backgroundGrayColor = UIColor(red:0.79, green:0.79, blue:0.79, alpha: 1.0)
        self.view.backgroundColor = backgroundGrayColor
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        self.outerView.addGestureRecognizer(downSwipe)
        self.shadowView.addGestureRecognizer(downSwipe)
        self.infoStackView.addGestureRecognizer(downSwipe)
    }
    
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) -> Void  {
        if gesture.direction == .down {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func hideChevronClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
