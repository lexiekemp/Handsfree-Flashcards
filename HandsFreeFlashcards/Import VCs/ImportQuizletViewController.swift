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
    var separatorOptions = [",",";","|","/"]
    var wordDefChoice = "," {
        didSet {
            wordDefButton.setTitle(wordDefChoice, for: .normal)
            wordDefButton.setTitle(wordDefChoice, for: .selected)
        }
    }
    var termsChoice = ";" {
        didSet {
            termsButton.setTitle(termsChoice, for: .normal)
            termsButton.setTitle(termsChoice, for: .selected)
        }
    }
    
    @IBOutlet weak var setTextView: UITextView!
    
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var wordDefButton: UIButton!
    @IBOutlet weak var wordDefTableView: UITableView!
    @IBOutlet weak var termsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tap)
        setTextView.delegate = self
        wordDefTableView.delegate = self
        termsTableView.delegate = self
        wordDefTableView.dataSource = self
        termsTableView.dataSource = self
        wordDefTableView.tag = 0
        termsTableView.tag = 1
        wordDefChoice = separatorOptions[0]
        termsChoice = separatorOptions[1]
        wordDefTableView.isHidden = true
        termsTableView.isHidden = true
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
            }
        })
    }
    private func checkSyntax(_ setToParse: String) -> Bool {
        var needChar = true
        var readingWord = true
        var needWordDefSep = false
        var termsSepOK = false
        for c in setToParse {
            if c == wordDefChoice[wordDefChoice.startIndex] {
                if (!needWordDefSep) {
                    return false
                }
                else {
                    readingWord = false
                    needWordDefSep = false
                    needChar = true
                }
            }
            else if c == termsChoice[termsChoice.startIndex] {
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
                    needWordDefSep = true
                    needChar = false
                }
                else {
                    termsSepOK = true
                    needChar = false
                }
            }
        }
        if (needWordDefSep || needChar) {
            return false
        }
        return true
    }
    private func parseText() -> Bool { //use text.components() instead to parse string into an array
        if managedObjectContext == nil {
            return false
        }
        if let setToParse = setTextView.text {
            if !checkSyntax(setToParse) {
                errorAlert(message: "Please enter correct syntax for set")
                return true
            }
            var currWord = ""
            var currDef = ""
            var readingWord = true
            for c in setToParse {
                if (c == wordDefChoice[wordDefChoice.startIndex]) {
                    readingWord = false
                }
                else if (c == termsChoice[termsChoice.startIndex]) {
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
    @IBAction func selectWordDef(_ sender: UIButton) {
        wordDefTableView.isHidden = !wordDefTableView.isHidden
    }
    @IBAction func selectTerms(_ sender: UIButton) {
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
        if tableView.tag == 0 { //wordDefTableView
            wordDefChoice = separatorOptions[indexPath.row]
        }
        else if tableView.tag == 1 { //termsTableView
            termsChoice = separatorOptions[indexPath.row]
        }
        tableView.isHidden = true
    }

}
