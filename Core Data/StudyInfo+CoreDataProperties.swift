//
//  StudyInfo+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension StudyInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StudyInfo> {
        return NSFetchRequest<StudyInfo>(entityName: "StudyInfo")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var rating: Int64
    @NSManaged public var parentSide: Side?

}
