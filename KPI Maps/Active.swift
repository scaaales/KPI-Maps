//
//  Active.swift
//  KPI Maps
//
//  Created by scales on 20.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import GoogleMaps

class Active {
        
    // MARK: - building
    private var buildingNumber: Int
    var building: Building!
    
    var buildingCenter: CLLocationCoordinate2D {
        let latitudeCenter = (building.southWest.latitude + building.northEast.latitude)/2
        let longitudeCenter = (building.southWest.longitude + building.northEast.longitude)/2
        return CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeCenter)
    }
    
    // MARK: - floor
    var floor: Int
    
    // MARK: - classroom
    var classroom: String! {
        didSet {
            self.setfloorBasedOn(classroom: classroom)
        }
    }
    
    var classroomLocation: CLLocationCoordinate2D? {
        return building.getClassroomWith(number: self.classroom)?.location
    }
    
    var classroomName: String? {
        return building.getClassroomWith(number: self.classroom)?.name
    }
    
    // MARK: - init's
    private init(buildingNumber: Int, floor: Int, classroom: String?) {
        self.buildingNumber = buildingNumber
        self.floor = floor
        self.classroom = classroom
        self.setBuildingWith(number: buildingNumber)
    }
    
    convenience init(buildingNumber: Int, floor: Int) {
        self.init(buildingNumber: buildingNumber, floor: floor, classroom: nil)
    }
    
    convenience init(buildingNumber: Int, classroom: String) {
        self.init(buildingNumber: buildingNumber, floor: 1, classroom: classroom)
        setfloorBasedOn(classroom: classroom)
    }
    
    // MARK: - private methods
    private func setBuildingWith(number: Int) {
        Database.dbQueue.inDatabase { db in
            do {
                self.building = try Building.fetchOne(db, key: ["number": "\(number)"])
            } catch {
                print("error = ", error)
            }
        }
    }
    
    // MARK: - getter's
    func getFloorFor(classroom: String) -> Int {
        return self.building.getClassroomWith(number: classroom)?.floor ?? 1
    }
    
    // MAKR: - setter's
    func setfloorBasedOn(classroom: String) {
        self.floor = getFloorFor(classroom: classroom)
    }
}
