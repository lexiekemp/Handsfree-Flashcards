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
    var sideOptions = ["Two", "Three", "Two and Three"]
    var sideChoice = 0 {
        didSet {
            sideChoiceButton.setTitle(sideOptions[sideChoice], for: .normal)
            sideChoiceButton.setTitle(sideOptions[sideChoice], for: .selected)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tap)
        setTextView.delegate = self
        sidesTableView.delegate = self
        termsTableView.delegate = self
        sideChoiceTableView.delegate = self
        sidesTableView.dataSource = self
        termsTableView.dataSource = self
        sideChoiceTableView.dataSource = self
        sidesTableView.tag = 0
        termsTableView.tag = 1
        sideChoiceTableView.tag = 2
        sideSepChoice = separatorOptions[0]
        cardsSepChoice = separatorOptions[1]
        sidesTableView.isHidden = true
        termsTableView.isHidden = true
        if set?.sideThreeName != nil && set?.sideThreeLangID != nil {
            sideOptions = [set!.sideTwoName!, set!.sideThreeName!, set!.sideTwoName! + "and" + set!.sideThreeName!]
            sideChoice = 0
            sideChoiceLabel.text = "Import" + set!.sideOneName! + "and"
        }
        else {
            sideChoiceLabel.isHidden = true
            sideChoiceButton.isHidden = true
            sideChoiceDownButton.isHidden = true
            sideChoice = 0
        }
        sideChoiceTableView.isHidden = true
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
            }
        })
    }
    private func checkSyntax(_ setToParse: String) -> Bool {
        var needChar = true
        var readingWord = true
        var needsidesSep = false
        var termsSepOK = false
        for c in setToParse {
            if c == sideSepChoice[sideSepChoice.startIndex] {
                if (!needsidesSep) {
                    return false
                }
                else {
                    readingWord = false
                    needsidesSep = false
                    needChar = true
                }
            }
            else if c == cardsSepChoice[cardsSepChoice.startIndex] {
                if (!termsSepOK) {
                    return false
                }
                else {
                    readingWord = true
                    termsSepOK = false
                }
            }
            else { //part of word or def
                if (readingWord) {
                    needsidesSep = true
                    needChar = false
                }
                else {
                    termsSepOK = true
                    needChar = false
                }
            }
        }
        if (needsidesSep || needChar) {
            return false
        }
        return true
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
            
            var cards = setToParse.components(separatedBy: cardsSepChoice)
            for card in cards {
                var sides = card.components(separatedBy: sideSepChoice)
                
            }
            var currWord = ""
            var currDef = ""
            var readingWord = true
            for c in setToParse {
                if (c == sideSepChoice[sideSepChoice.startIndex]) {
                    readingWord = false
                }
                else if (c == cardsSepChoice[cardsSepChoice.startIndex]) {
                    readingWord = true
                    _ = Card.addCard(word: currWord, definition: currDef, set: set!, inManagedObjectContext: managedObjectContext!)
                    currWord = ""
                    currDef = ""
                }
                else {
                    if (readingWord) {
                        currWord+=String(c)
                    }
                    else {
                        currDef+=String(c)
                    }
                }
            }
            if !currWord.isEmpty && !currDef.isEmpty {
                _ = Card.addCard(word: currWord, definition: currDef, set: set!, inManagedObjectContext: managedObjectContext!)
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
    @IBAction func selectSideChoice(_ sender: UIButton) {
        sideChoiceTableView.isHidden = !sideChoiceTableView.isHidden
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
        if tableView.tag == 2 {
            return sideOptions.count
        }
        return separatorOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sepOptCell", for: indexPath)
        if tableView.tag == 2 {
            cell.textLabel?.text = sideOptions[indexPath.row]
        }
        else {
            cell.textLabel?.text = separatorOptions[indexPath.row]
        }
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
