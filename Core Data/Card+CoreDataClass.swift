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
    class func addCard(date: NSDate, sideOne: String, sideTwo: String, sideThree: String?, set: Set, inManagedObjectContext context: NSManagedObjectContext) -> Card? {
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
            card.date = date
            card.sideOne = sideOne
            card.sideTwo = sideTwo
            card.sideThree = sideThree
            card.parentSet = set
            if let sideOne = Side.addSide(word: sideOne, index: 0, inManagedObjectContext: context) {
                card.addToSides(sideOne)
            }
            if let sideTwo = Side.addSide(word: sideTwo, index: 1, inManagedObjectContext: context) {
                card.addToSides(sideTwo)
            }
            if let sideThree = Side.addSide(word: sideThree ?? "", index: 2, inManagedObjectContext: context) {
                card.addToSides(sideThree)
            }
            do {
                try context.save()
            } catch {
                print("Failed saving card")
                return nil
            }
            return card
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
            do {
                try context.save()
            } catch {
                print("Failed saving delete")
            }
        }
    }
}
