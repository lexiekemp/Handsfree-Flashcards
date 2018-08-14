//
//  Card+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on One/One0/One8.
//  Copyright © Two0One8 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject {
    class func addCard(sideOne: String, sideTwo: String, sideThree: String?, set: Set, inManagedObjectContext context: NSManagedObjectContext) -> Card? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        if sideThree != nil {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@ AND sideThree = %@ AND parentSet = %@", sideOne, sideTwo, sideThree!, set)
        }
        else {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@ AND parentSet = %@", sideOne, sideTwo, set)
        }
        if let card = (try? context.fetch(request))?.first as? Card {
            return card
        }
        else if let card = NSEntityDescription.insertNewObject(forEntityName:"Card", into: context) as? Card {
            card.sideOne = sideOne
            card.sideTwo = sideTwo
            card.sideThree = sideThree
            card.parentSet = set
        }
        return nil
    }
    
    class func card(sideOne: String, sideTwo: String, sideThree: String?, set: Set, inManagedObjectContext context: NSManagedObjectContext) -> Card? {
        let request:NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        if sideThree != nil {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@ AND sideThree = %@ AND parentSet = %@", sideOne, sideTwo, sideThree!, set)
        }
        else {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@AND parentSet = %@", sideOne, sideTwo, set)
        }
        if let card = (try? context.fetch(request))?.first as? Card {
            return card
        }
        return nil
    }
    
    class func removeCard(sideOne: String, sideTwo: String, sideThree: String?, set: Set, inManagedObjectContext context: NSManagedObjectContext) {
        let request:NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        if sideThree != nil {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@ AND sideThree = %@ AND parentSet = %@", sideOne, sideTwo, sideThree!, set)
        }
        else {
            request.predicate = NSPredicate(format: "sideOne = %@ AND sideTwo = %@ AND parentSet = %@", sideOne, sideTwo, set)
        }
        
        if let card = (try? context.fetch(request))?.first as? Card {
            context.delete(card)
        }
    }
}
