//
//  SetsTableViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 11/17/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class SetsTableViewController: CoreDataTableViewController, UITextFieldDelegate {

    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() }}
    var selectedSets = [Set]()
    var setFirstResponder = false
    var setCount = 0
    var selectingMultiple = false {
        didSet {
            if !selectingMultiple {
                selectedSets.removeAll()
                selectMultipleButton.title = "Select Multiple"
                studyButton.title = ""
            }
            else {
                selectMultipleButton.title = "Cancel"
                studyButton.title = "Study"
            }
            tableView.reloadData()
        }
    }
    var selectedCards = [Card]()
    
    @IBOutlet weak var studyButton: UIBarButtonItem!
    
    @IBOutlet weak var selectMultipleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studyButton.title = ""
        self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        /*
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
            }
        })*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectingMultiple = false
        updateUI()
    }
    
    private func updateUI() {
        if let context = managedObjectContext {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Set")
            request.sortDescriptors = [NSSortDescriptor(key: "setName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            if let newCount = fetchedResultsController?.fetchedObjects?.count {
                setCount = newCount
            }
        }
        else {
            fetchedResultsController = nil
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            setCount = sections[section].numberOfObjects
            return sections[section].numberOfObjects
        } else {
            setCount = 0
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath) as! SetTableViewCell
        if let set = fetchedResultsController?.object(at: indexPath) as? Set {
            var name: String?
            set.managedObjectContext?.performAndWait {
                name = set.setName
            }
            if name != nil {
                cell.setTitleTextField.text = name!
            }
            cell.setTitleTextField.delegate = self
            cell.setTitleTextField.tag = indexPath.row
            cell.goToCardsButton.tag = indexPath.row
            if selectingMultiple {
                cell.goToCardsButton.setImage(#imageLiteral(resourceName: "unchecked-checkbox2"), for: .normal)
                cell.goToCardsButton.setImage(#imageLiteral(resourceName: "checked-checkbox2"), for: .selected)
                cell.goToCardsButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            }
            else {
                cell.goToCardsButton.isSelected = false
                cell.goToCardsButton.setImage(#imageLiteral(resourceName: "right_arrow_icon"), for: .normal)
            }
        }
        return cell
    }
    
    @IBAction func selectMultiple(_ sender: UIBarButtonItem) {
        selectingMultiple = !selectingMultiple
    }
    
    @IBAction func goToStudyModes(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToStudyModes", sender: nil)
    }
    
    @IBAction func goToCards(_ sender: UIButton) {
        if sender.tag < setCount {
            if let set = fetchedResultsController?.object(at: IndexPath(row:sender.tag, section:0)) as? Set {
                //selectedSets.append(set)
                if sender.isSelected {
                    if let i = selectedSets.index(of: set) {
                        selectedSets.remove(at: i)
                    }
                }
                else {
                    selectedSets.append(set)
                }
            }
        }
        else {
            tableView.reloadData()
        }
        if selectingMultiple {
            sender.isSelected = !sender.isSelected
        }
        else {
            self.performSegue(withIdentifier: "showCards", sender: nil)
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
            let cell = tableView.cellForRow(at: indexPath) as! SetTableViewCell
            if let setTitle = cell.setTitleTextField.text, managedObjectContext != nil {
                setCount = setCount - 1
                Set.removeSet(setName: setTitle, inManagedObjectContext: managedObjectContext!)
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
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newTitle = textField.text, newTitle.count > 0 {
            if textField.tag >= setCount {
                tableView.reloadData()
                errorAlert(message: "Failed to save new set name. Please try again.")
                return true
            }
            if let set = fetchedResultsController?.object(at: IndexPath(row:textField.tag, section:0)) as? Set {
                set.setName = newTitle
                do {
                    try managedObjectContext?.save()
                } catch {
                    errorAlert(message: "Failed to save new set name")
                }
            }
        }
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCards" {
            if let cardstvc = segue.destination as? CardsTableViewController, !selectedSets.isEmpty {
                cardstvc.parentSet = selectedSets[0]
                cardstvc.setFirstResponder = setFirstResponder
                setFirstResponder = false
            }
        }
        else if segue.identifier == "createSet" {
            if let createSetvc = segue.destination as? NewSetViewController {
                createSetvc.parentSetTVC = self
            }
        }
        else if segue.identifier == "goToStudyModes" {
            if let studyModevc = segue.destination as? StudyModeViewController {
                studyModevc.studySets = selectedSets
            }
        }
    }
}
