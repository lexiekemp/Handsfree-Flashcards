//
//  StudyInfo+CoreDataClass.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData

@objc(StudyInfo)
public class StudyInfo: NSManagedObject {
    class func addStudyInfo(rating: Int64, date: NSDate, inManagedObjectContext context: NSManagedObjectContext) -> StudyInfo? {
        if let studyInfo = NSEntityDescription.insertNewObject(forEntityName:"StudyInfo", into: context) as? StudyInfo {
            studyInfo.rating = rating
            studyInfo.date = date
            do {
                try context.save()
            } catch {
                print("Failed saving study info")
                return nil
            }
            return studyInfo
        }
        return nil
    }
    class func studyInfoByDate(side: Side, inManagedObjectContext context: NSManagedObjectContext) -> [StudyInfo] {
        var infoArray = (side.studyInfo?.allObjects as? [StudyInfo]) ?? [StudyInfo]()
        infoArray.sort(by: { ($0.date! as Date).compare($1.date! as Date) == .orderedDescending })
        return infoArray
    }
}
