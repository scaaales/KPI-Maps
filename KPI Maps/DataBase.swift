//
//  DataBase.swift
//  KPI Maps
//
//  Created by scales on 20.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import GRDB
import UIKit
import GoogleMaps

protocol SearchName {
    var name: String { get }
}

class Database: NSObject {
    static var dbQueue: DatabaseQueue!
    
    static func open() {
        if let databasePath = Bundle.main.path(forResource: "KPIMaps", ofType: "db") {
            do {
                dbQueue = try DatabaseQueue(path: databasePath)
            } catch {
                print("error = \(error)")
            }
        }
    }
    
    static let allObjectsNames: [String] = {
        var result: [String] = []
        
        for building in allBuildings {
            result.append(building.name)
        }
        
        for classroom in allClassrooms {
            result.append(classroom.name)
        }
        
        return result
    }()
    
    static let allBuildings: [Building] = {
        var result: [Building] = []
        
        dbQueue.inDatabase { db in
            do {
                result = try Building.fetchAll(db)
            } catch {
                print("error = \(error)")
            }
        }
        
        return result
    }()

    static let allClassrooms: [Classroom] = {
        var result: [Classroom] = []
        
        dbQueue.inDatabase { db in
            do {
                result = try Classroom.fetchAll(db)
            } catch {
                print("error = \(error)")
            }
        }
        
        return result
    }()
    
    static func getClassroom(_ classroomNumber: String, inBuilding buildingNumber: Int) -> Classroom? {
        
        for classroom in allClassrooms where ((classroom.buildingNumber == buildingNumber) && (classroom.number == classroomNumber)) {
            return classroom
        }
        
        return nil
    }
}
