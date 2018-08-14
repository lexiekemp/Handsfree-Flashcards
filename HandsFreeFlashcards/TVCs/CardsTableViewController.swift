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
        self.navigationItem.title = parentSet?.setName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        if let context = managedObjectContext, parentSet != nil {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
            request.predicate = NSPredicate(format:"parentSet.name = %@", parentSet!.setName!)
            request.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            if let newCount = fetchedResultsController?.fetchedObjects?.count {
                cardCount = newCount
            }
            
            
            
//            if parentSet?.sideThreeName != nil {
//                sideThreeTextField = UITextField()
//                cardCellView.addSubview(sideThreeTextField!)
//                sideThreeTextField!.widthAnchor.constraint(equalTo: sideOneTextField.widthAnchor).isActive = true
//                sideThreeTextField!.topAnchor.constraint(equalTo: cardCellView.topAnchor, constant: 10).isActive = true
//                sideThreeTextField!.leadingAnchor.constraint(equalTo: sideTwoTextField.trailingAnchor)
//                sideThreeTextField!.bottomAnchor.constraint(equalTo: cardCellView.bottomAnchor, constant: 10).isActive = true
//                sideThreeTextField!.trailingAnchor.constraint(equalTo: cardCellView.trailingAnchor).isActive = true
//                sideThreeTextField!.heightAnchor.constraint(equalTo: sideOneTextField.heightAnchor).isActive = true
//
//            }
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
        if indexPath.row == 1 {
            cell.sideOneTextField?.text = parentSet?.sideOneName
            cell.sideTwoTextField?.text = parentSet?.sideTwoName
            if parentSet?.sideThreeName != nil {
                cell.sideThreeTextField?.text = parentSet?.sideThreeName!
            }
        }
        else if indexPath.row < cardCount {
            if let card = fetchedResultsController?.object(at: (indexPath)) as? Card { //TODO: make sure index Path is corrent and not offset by one
                var sideOneWord = ""
                var sideTwoWord = ""
                var sideThreeWord = ""
                card.managedObjectContext?.performAndWait { //TODO: REALLY NEED PERFORM AND WAIT HERE?
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
        let twoToView = NSLayoutConstraint(item: cell.sideTwoTextField, attribute: .trailing, relatedBy: .equal, toItem: cell.cardCellView, attribute: .trailing, multiplier: 0, constant: 10)
        let twoToThree = NSLayoutConstraint(item: cell.sideTwoTextField, attribute: .trailing, relatedBy: .equal, toItem: cell.sideThreeTextField, attribute: .leading, multiplier: 0, constant: 0)
        if parentSet?.sideThreeName == nil {
            cell.sideThreeTextField.removeFromSuperview()
            cell.sideTwoTextField.addConstraint(twoToView)
        }
        else {
            cell.cardCellView.addSubview(cell.sideThreeTextField)
            cell.sideTwoTextField.removeConstraint(twoToView)
            cell.sideTwoTextField.addConstraint(twoToThree)
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
                if let sideThree = cell.sideThreeTextField.text {
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
    
    func textFieldUpdate(_ textField: UITextField) {
        if let text = textField.text {
            if text.count > 0 {
                let currTag = textField.tag
                let cardRow = currTag/3
                let indexPath = IndexPath(row: cardRow, section: 0)
                if (cardRow-1) < cardCount { //update existing card
                    setFirstResponder = false
                    textField.resignFirstResponder()
                    if let card = fetchedResultsController?.object(at: indexPath) as? Card {
                        if currTag%3 == 0 { //sideOne
                            card.sideOne = text
                        }
                        else if currTag%3 == 1 { //sideTwo
                            card.sideTwo = text
                        }
                        else {
                            card.sideThree = text
                        }
                        do {
                            try managedObjectContext?.save()
                        } catch {
                            errorAlert(message: "Failed to save card")
                        }
                    }
                }
                else if (cardRow-1) == cardCount { //creating new card
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
                                if Card.addCard(sideOne: sideOneText!, sideTwo: sideTwoText!, sideThree: text, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    errorAlert(message: "Cannot create duplicate cards.")
                                    cell.sideOneTextField.becomeFirstResponder()
                                }
                                else {
                                    setFirstResponder = true
                                }
                            }
                            else { //sideTwo, no sideThree
                                if Card.addCard(sideOne: sideOneText!, sideTwo: text, sideThree: nil, set: parentSet!, inManagedObjectContext: managedObjectContext!) != nil {
                                    errorAlert(message: "Cannot create duplicate cards.")
                                    cell.sideOneTextField.becomeFirstResponder()
                                }
                                else {
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

