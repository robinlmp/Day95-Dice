//
//  DiceRoll+CoreDataProperties.swift
//  DiceRoll
//
//  Created by Robin Phillips on 29/08/2021.
//
//

import Foundation
import CoreData


extension DiceRoll {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiceRoll> {
        return NSFetchRequest<DiceRoll>(entityName: "DiceRoll")
    }

    @NSManaged public var result: Int16
    @NSManaged public var resultText: String?
    @NSManaged public var timeOfRoll: Date?
    @NSManaged public var id: UUID?
    
    
    public var wrapResultText: String {
        resultText ?? "Unknown result"
    }
    
    var wrapTimeOfRoll: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        if let timeOfRoll = timeOfRoll {
            return dateFormatter.string(from: timeOfRoll)
        } else {
            return "unknown date"
        }
    }
    
    public var wrapID: UUID {
        id ?? UUID()
    }
    

}

extension DiceRoll : Identifiable {

}
