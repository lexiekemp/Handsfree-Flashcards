//
//  SideInfo+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/24/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SideInfo)
public class SideInfo: NSManagedObject {
    class func addSideInfo(name: String, langID: String, index: Int64, inManagedObjectContext context: NSManagedObjectContext) -> SideInfo? {
        if let sideInfo = NSEntityDescription.insertNewObject(forEntityName:"SideInfo", into: context) as? SideInfo {
            sideInfo.name = name
            sideInfo.index = index
            sideInfo.langID = langID
            do {
                try context.save()
            } catch {
                print("Failed saving side info")
                return nil
            }
            return sideInfo
        }
        return nil
    }
}
