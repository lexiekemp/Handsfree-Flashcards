//
//  Set+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on One/One0/One8.
//  Copyright © Two0One8 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Set)
public class Set: NSManagedObject {
    class func addSet(setName: String, sideOneLangID: String, sideTwoLangID: String, sideThreeLangID: String?, sideOneName: String, sideTwoName: String, sideThreeName: String?, inManagedObjectContext context: NSManagedObjectContext) -> Set? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Set")
       // let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "setName = %@", setName)
        
        if let set = (try? context.fetch(request))?.first as? Set {
            return set
        }
        else if let set = NSEntityDescription.insertNewObject(forEntityName:"Set", into: context) as? Set {
            set.setName = setName
            set.sideOneLangID = sideOneLangID
            set.sideTwoLangID = sideTwoLangID
            set.sideThreeLangID = sideThreeLangID
            set.sideOneName = sideOneName
            set.sideTwoName = sideTwoName
            set.sideThreeName = sideThreeName
            return set
        }
        return nil
    }
    class func set(withName setName: String, inManagedObjectContext context: NSManagedObjectContext) -> Set? {
        let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "setName = %@", setName)
        
        if let set = (try? context.fetch(request))?.first as? Set {
            return set
        }
        return nil
    }
    class func removeSet(setName: String, inManagedObjectContext context: NSManagedObjectContext) {
        let request:NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        request.predicate = NSPredicate(format: "setName = %@", setName)
        if let set = (try? context.fetch(request))?.first as? Set {
            context.delete(set)
        }
    }
}
