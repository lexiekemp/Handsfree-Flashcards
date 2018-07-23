//
//  Card+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/10/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject {
    class func addCard(word: String, definition: String, set: Set, inManagedObjectContext context: NSManagedObjectContext) -> Card? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        request.predicate = NSPredicate(format: "word = %@ AND definition = %@ AND parentSet = %@", word, definition, set)
        if let card = (try? context.fetch(request))?.first as? Card {
            return card
        }
        else if let card = NSEntityDescription.insertNewObject(forEntityName:"Card", into: context) as? Card {
            card.word = word
            card.definition = definition
            card.parentSet = set
        }
        return nil
    }
    
    class func card(word: String, definition: String, set: Set, inManagedObjectContext context: NSManagedObjectContext) -> Card? {
        let request:NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "word = %@ AND definition = %@ AND parentSet = %@", word, definition, set)
        
        if let card = (try? context.fetch(request))?.first as? Card {
            return card
        }
        return nil
    }
    
    class func removeCard(word: String, definition: String, set: Set, inManagedObjectContext context: NSManagedObjectContext) {
        let request:NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "word = %@ AND definition = %@ AND parentSet = %@", word, definition, set)
        
        if let card = (try? context.fetch(request))?.first as? Card {
            context.delete(card)
        }
    }
}
