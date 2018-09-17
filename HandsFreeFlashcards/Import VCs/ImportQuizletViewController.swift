//
//  ImportQuizletViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/1/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class ImportQuizletViewController: RootViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var set:Set?
    var managedObjectContext:NSManagedObjectContext?
    let separatorOptions = [",",";","|","/"]
    var sideSepChoice = "," {
        didSet {
            sidesButton.setTitle(sideSepChoice, for: .normal)
            sidesButton.setTitle(sideSepChoice, for: .selected)
        }
    }
    var cardsSepChoice = ";" {
        didSet {
            termsButton.setTitle(cardsSepChoice, for: .normal)
            termsButton.setTitle(cardsSepChoice, for: .selected)
        }
    }

    @IBOutlet weak var setTextView: UITextView!
    
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var sidesButton: UIButton!
    @IBOutlet weak var sidesTableView: UITableView!
    @IBOutlet weak var termsTableView: UITableView!
    @IBOutlet weak var numSidesSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tap)
        setTextView.delegate = self
        sidesTableView.delegate = self
        termsTableView.delegate = self
        sidesTableView.dataSource = self
        termsTableView.dataSource = self
        sidesTableView.tag = 0
        termsTableView.tag = 1
        sideSepChoice = separatorOptions[0]
        cardsSepChoice = separatorOptions[1]
        sidesTableView.isHidden = true
        termsTableView.isHidden = true
        if set?.sideThreeName == nil || set?.sideThreeLangID == nil {
            numSidesSegControl.setEnabled(false, forSegmentAt: 1)
        }
    }
    
    private func parseText() -> Bool { //use text.components() instead to parse string into an array
        if managedObjectContext == nil {
            return false
        }
        if let setToParse = setTextView.text {
//            if !checkSyntax(setToParse) {
//                errorAlert(message: "Please enter correct syntax for set")
//                return true
//            }
            
            let cards = setToParse.components(separatedBy: cardsSepChoice)
            for card in cards {
                var sides = card.components(separatedBy: sideSepChoice)
                if set?.sideThreeName != nil && set?.sideThreeLangID != nil && numSidesSegControl.selectedSegmentIndex == 1 {
                    if sides.count != 3 {
                        errorAlert(message: "Please enter correct syntax for importing 3 sides")
                        return true
                    }
                    _ = Card.addCard(sideOne: sides[0], sideTwo: sides[1], sideThree: sides[2], set: set!, inManagedObjectContext: managedObjectContext!)
                }
                else {
                    if sides.count != 2 {
                        errorAlert(message: "Please enter correct syntax for importing 2 sides")
                        return true
                    }
                    _ = Card.addCard(sideOne: sides[0], sideTwo: sides[1], sideThree: nil, set: set!, inManagedObjectContext: managedObjectContext!)
                }
            }
        }
        return true
    }
    
    @IBAction func addCards(_ sender: UIButton) {
        if managedObjectContext == nil {
            errorAlert(message: "Context is nil.")
            return
        }
        if setTextView.text == nil {
            errorAlert(message: "Please enter text or cancel")
        }
        if set != nil {
            if !parseText() {
                errorAlert(message: "Cards could not be saved")
                return
            }
        }
        else {
            errorAlert(message: "set is nil.")
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func selectSideSep(_ sender: UIButton) {
        sidesTableView.isHidden = !sidesTableView.isHidden
    }
    @IBAction func selectTermSep(_ sender: UIButton) {
        termsTableView.isHidden = !termsTableView.isHidden
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.setTextView.resignFirstResponder()
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return separatorOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sepOptCell", for: indexPath)
        cell.textLabel?.text = separatorOptions[indexPath.row]
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 { //sidesTableView
            sideSepChoice = separatorOptions[indexPath.row]
        }
        else if tableView.tag == 1 { //termsTableView
            cardsSepChoice = separatorOptions[indexPath.row]
        }
        tableView.isHidden = true
    }

}
