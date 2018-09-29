//
//  Side+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Side)
public class Side: NSManagedObject {
    class func addSide(word: String, index: Int64, inManagedObjectContext context: NSManagedObjectContext) -> Side? {
        if let side = NSEntityDescription.insertNewObject(forEntityName:"Side", into: context) as? Side {
            side.word = word
            side.index = index
            do {
                try context.save()
            } catch {
                print("Failed saving side")
                return nil
            }
            return side
        }
        return nil
    }
}
