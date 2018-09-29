//
//  Side+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension Side {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Side> {
        return NSFetchRequest<Side>(entityName: "Side")
    }

    @NSManaged public var index: Int64
    @NSManaged public var word: String?
    @NSManaged public var studyInfo: NSSet?
    @NSManaged public var parentCard: Card?

}

// MARK: Generated accessors for studyInfo
extension Side {

    @objc(addStudyInfoObject:)
    @NSManaged public func addToStudyInfo(_ value: StudyInfo)

    @objc(removeStudyInfoObject:)
    @NSManaged public func removeFromStudyInfo(_ value: StudyInfo)

    @objc(addStudyInfo:)
    @NSManaged public func addToStudyInfo(_ values: NSSet)

    @objc(removeStudyInfo:)
    @NSManaged public func removeFromStudyInfo(_ values: NSSet)

}
