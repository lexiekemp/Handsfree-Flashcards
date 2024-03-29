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
    var activeTextField: UITextField?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = parentSet?.setName
         self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let textField = activeTextField {
            textFieldUpdate(textField)
        }
    }
    private func updateUI() {
        if let context = managedObjectContext, parentSet != nil {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
            request.predicate = NSPredicate(format:"parentSet.setName = %@", parentSet!.setName!)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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
            return sections[section].numberOfObjects + 2
        } else {
            cardCount = 0
            return 2
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardTableViewCell
        updateCardCellUI(cell)
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            if parentSet?.sideOneName != nil {
                cell.sideOneTextField?.attributedText = NSAttributedString(string: parentSet!.sideOneName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 16.0)])
            }
            if parentSet?.sideTwoName != nil {
                cell.sideTwoTextField?.attributedText = NSAttributedString(string: parentSet!.sideTwoName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 16.0)])
            }
            if parentSet?.sideThreeName != nil {
                cell.sideThreeTextField?.attributedText = NSAttributedString(string: parentSet!.sideThreeName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 16.0)])
            }
        }
        else if indexPath.row < (cardCount + 1) {
            let newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if let card = fetchedResultsController?.object(at: (newIndexPath)) as? Card { 
                var sideOneWord = ""
                var sideTwoWord = ""
                var sideThreeWord = ""
                card.managedObjectContext?.performAndWait {
                    if (card.sideOne != nil) {
                        sideOneWord = card.sideOne!
                    }
                    if (card.sideTwo != nil) {
                        sideTwoWord = card.sideTwo!
                    }
                    if (card.sideThree != nil) {
                        sideThreeWord = card.sideThree!
                    }
                }
                cell.sideOneTextField?.text = sideOneWord
                cell.sideTwoTextField?.text = sideTwoWord
                cell.sideThreeTextField?.text = sideThreeWord
            }
        }
        else {
            cell.sideOneTextField?.text = ""
            cell.sideTwoTextField?.text = ""
            cell.sideThreeTextField?.text = ""
            
            cell.sideOneTextField?.placeholder = "new"
            cell.sideTwoTextField?.placeholder = "new"
            cell.sideThreeTextField?.placeholder = "new"
          
            if setFirstResponder == true {
                cell.sideOneTextField.becomeFirstResponder()
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        cell.sideOneTextField?.tag = (indexPath.row)*3
        cell.sideTwoTextField?.tag = (indexPath.row)*3 + 1
        cell.sideThreeTextField?.tag = (indexPath.row)*3 + 2
        
        cell.sideOneTextField?.delegate = self
        cell.sideTwoTextField?.delegate = self
        cell.sideThreeTextField?.delegate = self
        return cell
    }
    
    private func updateCardCellUI(_ cell: CardTableViewCell) {
        if parentSet?.sideThreeName == nil {
            cell.sideThreeTextField?.removeFromSuperview()
            let twoToView = NSLayoutConstraint(item: cell.sideTwoTextField, attribute: .trailing, relatedBy: .equal, toItem: cell.cardCellView, attribute: .trailing, multiplier: 1.0, constant: 10.0)
            cell.cardCellView.addConstraint(twoToView)
        }
        else {
            cell.cardCellView.addSubview(cell.sideThreeTextField)
            let twoToThree = NSLayoutConstraint(item: cell.sideTwoTextField, attribute: .trailing, relatedBy: .equal, toItem: cell.sideThreeTextField, attribute: .leading, multiplier: 1.0, constant: 0.0)
            cell.cardCellView.addConstraint(twoToThree)
        }
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
            if let sideOne = cell.sideOneTextField.text, let sideTwo = cell.sideTwoTextField.text, managedObjectContext != nil, parentSet != nil {
                cardCount = cardCount - 1
                if let sideThree = cell.sideThreeTextField?.text {
                    Card.removeCard(sideOne: sideOne, sideTwo: sideTwo, sideThree: sideThree, set: parentSet!, inManagedObjectContext: managedObjectContext!)
                }
                else {
                    Card.removeCard(sideOne: sideOne, sideTwo: sideTwo, sideThree: nil, set: parentSet!, inManagedObjectContext: managedObjectContext!)
                }
                tableView.reloadData()
            }
            else {
                errorAlert(message: "Error removing card")
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
        if oldTag >= (cardCount+1)*3 { //sideOne, move on to sideTwo
            let cell = tableView.cellForRow(at: IndexPath(row: oldTag/3, section: 0)) as! CardTableViewCell
            if oldTag%3 == 0 {
                cell.sideTwoTextField.becomeFirstResponder()
            }
            else if oldTag%3 == 1, parentSet?.sideThreeName != nil {
                cell.sideThreeTextField.becomeFirstResponder()
            }
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    func textFieldUpdate(_ textField: UITextField) {
        if let text = textField.text {
            let currTag = textField.tag
            let cardRow = currTag/3
            let indexPath = IndexPath(row: cardRow - 1, section: 0)
            if text.count > 0 {
                if cardRow == 0 { //updating row titles
                    setFirstResponder = false
                    textField.resignFirstResponder()
                    if currTag%3 == 0 { //sideOne
                        parentSet?.sideOneName = text
                    }
                    else if currTag%3 == 1 { //sideTwo
                        parentSet?.sideTwoName = text
                    }
                    else { //sideThree
                        parentSet?.sideThreeName = text
                    }
                    do {
                        try managedObjectContext?.save()
                    } catch {
                        errorAlert(message: "Failed to save card")
                    }
                }
                else if (cardRow) <= cardCount { //update existing card
                    setFirstResponder = false
                    textField.resignFirstResponder()
                    if let card = fetchedResultsController?.object(at: indexPath) as? Card {
                        if currTag%3 == 0 { //sideOne
                            card.sideOne = text
                        }
                        else if currTag%3 == 1 { //sideTwo
                            card.sideTwo = text
                        }
                        else { //sideThree
                            card.sideThree = text
                        }
                        do {
                            try managedObjectContext?.save()
                        } catch {
                            errorAlert(message: "Failed to save card")
                        }
                    }
                }
                else if cardRow > cardCount { //creating new card
                    if managedObjectContext != nil, parentSet != nil {
                        if (currTag%3 == 1 && parentSet!.sideThreeName == nil) || (currTag%3 == 2) { //finished editing card
                            let cell = tableView.cellForRow(at: IndexPath(row: currTag/3, section: 0)) as! CardTableViewCell
                            var sideOneText = cell.sideOneTextField.text
                            if sideOneText != nil, sideOneText!.count == 0 {
                                sideOneText = " "
                            }
                            if currTag%3 == 2 {//sideThree
                                var sideTwoText = cell.sideTwoTextField.text
                                if sideTwoText != nil, sideTwoText!.count == 0 {
                                    sideTwoText = " "
                                }
                                if Card.card(sideOne: sideOneText!, sideTwo: sideTwoText!, sideThree: text, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    errorAlert(message: "Cannot create duplicate cards.")
                                    cell.sideOneTextField.becomeFirstResponder()
                                }
                                else if Card.addCard(date: NSDate(), sideOne: sideOneText!, sideTwo: sideTwoText!, sideThree: text, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    setFirstResponder = true
                                }
                            }
                            else { //sideTwo, no sideThree
                                if Card.card(sideOne: sideOneText!, sideTwo: text, sideThree: nil, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    errorAlert(message: "Cannot create duplicate cards.")
                                    cell.sideOneTextField.becomeFirstResponder()
                                }
                                else if Card.addCard(date: NSDate(), sideOne: sideOneText!, sideTwo: text, sideThree: nil, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    setFirstResponder = true
                                }
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
                updateUI()
            }
            else if cardRow > cardCount {
                setFirstResponder = false
                textField.resignFirstResponder()
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
            if let navC = segue.destination as? UINavigationController, parentSet != nil {
                if let importQuizletvc = navC.topViewController as? ImportQuizletViewController {
                    importQuizletvc.set = parentSet!
                }
            }
        }
    }
    
}

