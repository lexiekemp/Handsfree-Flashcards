//
//  CardsTableViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/1/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class CardsTableViewController: CoreDataTableViewController, UITextFieldDelegate {
    
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() }}
    var parentSet: Set?
    var cardCount = 0
    var setFirstResponder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = parentSet?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        if let context = managedObjectContext, parentSet != nil {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
            request.predicate = NSPredicate(format:"parentSet.name = %@", parentSet!.name!)
            request.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            if let newCount = fetchedResultsController?.fetchedObjects?.count {
                cardCount = newCount
            }
        }
        else {
            fetchedResultsController = nil
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            cardCount = sections[section].numberOfObjects
            return sections[section].numberOfObjects + 1
        } else {
            cardCount = 0
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardTableViewCell
        if indexPath.row < cardCount {
            if let card = fetchedResultsController?.object(at: indexPath) as? Card {
                var word = ""
                var definition = ""
                card.managedObjectContext?.performAndWait { //TODO: REALLY NEED PERFORM AND WAIT HERE?
                    if (card.word != nil && card.definition != nil) {
                        word = card.word!
                        definition = card.definition!
                    }
                }
                cell.wordTextField?.text = word
                cell.defTextField?.text = definition
            }
        }
        else {
            cell.wordTextField?.text = ""
            cell.defTextField?.text = ""
            cell.wordTextField?.placeholder = "new word"
            cell.defTextField?.placeholder = "new def"
            if setFirstResponder == true {
                cell.wordTextField.becomeFirstResponder()
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        cell.wordTextField?.tag = indexPath.row*2
        cell.defTextField?.tag = indexPath.row*2 + 1
        cell.wordTextField?.delegate = self
        cell.defTextField?.delegate = self
        return cell
    }
    
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     return true
     }
    
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let cell = tableView.cellForRow(at: indexPath) as! CardTableViewCell
            if let word = cell.wordTextField.text, let def = cell.defTextField.text, managedObjectContext != nil, parentSet != nil {
                cardCount = cardCount - 1
                Card.removeCard(word: word, definition: def, set: parentSet!, inManagedObjectContext: managedObjectContext!)
                tableView.reloadData()
            }
            else {
                errorAlert(message: "Error removing set")
            }
        }
     }
    
    func errorAlert(message: String) {
        let alertController = UIAlertController(title:"Error", message: message, preferredStyle:.alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated:true, completion:nil)
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let oldTag = textField.tag
        textFieldUpdate(textField)
        if oldTag%2 == 0, oldTag == cardCount*2 { //word, move on to definition
            let cell = tableView.cellForRow(at: IndexPath(row: oldTag/2, section: 0)) as! CardTableViewCell
            cell.defTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldUpdate(_ textField: UITextField) {
        if let text = textField.text {
            if text.count > 0 {
                let currTag = textField.tag
                let cardNum = currTag/2
                let indexPath = IndexPath(row: cardNum, section: 0)
                if cardNum < cardCount { //update existing card
                    setFirstResponder = false
                    textField.resignFirstResponder()
                    if let card = fetchedResultsController?.object(at: indexPath) as? Card {
                        if currTag%2 == 0 { //word
                            card.word = text
                            do {
                                try managedObjectContext?.save()
                            } catch {
                                errorAlert(message: "Failed to save card")
                            }
                        }
                        else { //definition
                            card.definition = text
                            do {
                                try managedObjectContext?.save()
                            } catch {
                                errorAlert(message: "Failed to save card")
                            }
                        }
                    }
                }
                else if cardNum == cardCount { //creating new card
                    if managedObjectContext != nil, parentSet != nil {
                        if currTag%2 == 1 { //def
                            let cell = tableView.cellForRow(at: IndexPath(row: currTag/2, section: 0)) as! CardTableViewCell
                            var wordText = cell.wordTextField.text
                            if wordText != nil, wordText!.count == 0 {
                                wordText = " "
                            }
                            if Card.addCard(word: wordText!, definition: text, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                errorAlert(message: "Cannot create duplicate cards.")
                                cell.wordTextField.becomeFirstResponder()
                            }
                            else {
                                setFirstResponder = true
                            }
                        }
                        else {
                            setFirstResponder = false
                            return
                        }
                    }
                }
                else {
                    errorAlert(message: "Failed to save card. Please try again.")
                }
                tableView.reloadData()
            }
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "study" {
            if let studyModevc = segue.destination as? StudyModeViewController, parentSet != nil {
                studyModevc.studySets = [parentSet!]
            }
        }
        if segue.identifier == "import" {
            //todo：because segue is to nav controller, need to get out actual vc
            if let navC = segue.destination as? UINavigationController, parentSet != nil {
                if let importQuizletvc = navC.topViewController as? ImportQuizletViewController {
                    importQuizletvc.set = parentSet!
                }
            }
        }
    }
    
}

