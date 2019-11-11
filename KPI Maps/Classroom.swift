//
//  Classroom.swift
//  KPI Maps
//
//  Created by scales on 20.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import CoreLocation
import GRDB

class Classroom: Record, SearchName {
    var id: Int64?
    var number: String
    var buildingNumber: Int
    var floor: Int
    var location: CLLocationCoordinate2D
    
    override class var databaseTableName: String {
        return "classrooms"
    }
    
    var name: String {
        return "\(buildingNumber) корпус \(number) аудиторія"
    }
    
    required init(row: Row) {
        id = row["id"]
        number = row["number"]
        buildingNumber = row["buildingNumber"]
        floor = row["floor"]
        let latitude: Double = row["latitude"]
        let longitude: Double = row["longitude"]
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        super.init(row: row)
    }
    
}

