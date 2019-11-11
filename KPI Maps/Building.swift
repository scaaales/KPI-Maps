//
//  Building.swift
//  KPI Maps
//
//  Created by scales on 20.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import CoreLocation
import GRDB
import GoogleMaps

class Building: Record, SearchName {
    var id: Int64?
    var number: Int
    var numberOfFloors: Int
    var southWest: CLLocationCoordinate2D
    var northEast: CLLocationCoordinate2D
    
    var coordinateBounds: GMSCoordinateBounds {
        return GMSCoordinateBounds(coordinate: self.southWest, coordinate: self.northEast)
    }
    
    override class var databaseTableName: String {
        return "buildings"
    }
    
    var name: String {
        return "\(number) корпус"
    }
    
    required init(row: Row) {
        id = row["id"]
        number = row["number"]
        numberOfFloors = row["numberOfFloors"]
        
        let southLatitude: Double = row["southLatitude"]
        let westLongitude: Double = row["westLongitude"]
        let northLatitude: Double = row["northLatitude"]
        let eastLongitude: Double = row["eastLongitude"]
        
        southWest = CLLocationCoordinate2D(latitude: southLatitude, longitude: westLongitude)
        northEast = CLLocationCoordinate2D(latitude: northLatitude, longitude: eastLongitude)
        
        super.init(row: row)
    }
    
    func getClassroomWith(number: String) -> Classroom? {
        
        return Database.getClassroom(number, inBuilding: self.number)
        
    }
}
