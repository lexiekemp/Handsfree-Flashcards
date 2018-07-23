//
//  CardsTableViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 12/30/17.
//  Copyright © 2017 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData
/*
class CardsTableViewController: CoreDataTableViewController {

    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() }}
    var parentSet: Set?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = parentSet?.name
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
            }
        })
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
        }
        else {
            fetchedResultsController = nil
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardTableViewCell
        if let card = fetchedResultsController?.object(at: indexPath) as? Card {
            var word = ""
            var definition = ""
            card.managedObjectContext?.performAndWait { //TODO: REALLY NEED PERFORM AND WAIT HERE?
                if (card.word != nil && card.definition != nil) {
                    word = card.word!
                    definition = card.definition!
                }
            }
            cell.wordLabel?.text = word
            cell.defLabel?.text = definition
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "study" {
            if let studyModevc = segue.destination as? StudyModeViewController, parentSet != nil {
                studyModevc.studySet = parentSet!
            }
        }
    }

}*/
