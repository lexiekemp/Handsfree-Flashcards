//
//  Set+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/10/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Set)
public class Set: NSManagedObject {
    class func addSet(name: String, wordLangID: String, defLangID: String, inManagedObjectContext context: NSManagedObjectContext) -> Set? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Set")
       // let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        
        if let set = (try? context.fetch(request))?.first as? Set {
            return set
        }
        else if let set = NSEntityDescription.insertNewObject(forEntityName:"Set", into: context) as? Set {
            set.name = name
            set.wordLangID = wordLangID
            set.defLangID = defLangID
            return set
        }
        return nil
    }
    class func set(withName name: String, inManagedObjectContext context: NSManagedObjectContext) -> Set? {
        let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        
        if let set = (try? context.fetch(request))?.first as? Set {
            return set
        }
        return nil
    }
    class func removeSet(name: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        if let set = (try? context.fetch(request))?.first as? Set {
            context.delete(set)
        }
    }
}
