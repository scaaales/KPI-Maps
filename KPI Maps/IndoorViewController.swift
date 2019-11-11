//
//  IndoorViewController.swift
//  KPI Maps
//
//  Created by scales on 21.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import GoogleMaps
import UIKit

// MARK: delegate protocol
protocol IndoorViewControllerDelegate: class {
    var mapView: GMSMapView { get }
    func startIndoorMapping()
}

// MARK: IndoorViewController class
class IndoorViewController: NSObject {
    // MARK: - properties
    // MARK: public
    weak var delegate: IndoorViewControllerDelegate?
    
    // MARK: private
    // MARK: view
    private var floorButtons = [UIButton]()
    private var infoLabel: UILabel!
    private var overlays = [Int: GMSGroundOverlay]()
    
    // MARK: active instance
    private var active: Active? {
        willSet {
            if active != nil {
                overlays[active!.building.number]!.icon = UIImage(named: "\(active!.building.number)-1")
            }
            if newValue?.classroom != nil {
                overlays[newValue!.building.number]!.icon = UIImage(named: "\(newValue!.building.number)-\(newValue!.floor)")
            }
        }
        didSet {
            if active != nil {
                createButtonsForFloors()
                if oldValue == nil {
                    // first active building
                    showButtons()
                    createLabel()
                } else {
                    // changed active building
                    redrawButtons()
                    updateLabel()
                }
            } else {
                // no active building
                deleteButtons()
                deleteLabel()
            }
        }
    }
    
    // MARK: - Init's
    override init() {
        super.init()
    }
    
    init(building: Int, classroom: String) {
        self.active = Active(buildingNumber: building, classroom: classroom)
        super.init()
    }
    
    init(building: Int, floor: Int) {
        self.active = Active(buildingNumber: building, floor: floor)
        super.init()
    }
    
    // MARK: - Public methods
    func startIndoor() {
        if delegate != nil {
            showBuildings()
            updateActiveBuilding()
        }
    }
    
    func updateActiveBuilding() {
//        print((active == nil ? "nil" : active!.building.number))
        if active == nil {
            // there is no active building
            if let number = findVisibleBuildingNumber() {
                // if building on the screen
                active = Active(buildingNumber: number, floor: 1)
            }
        } else {
            if active?.building.number != findVisibleBuildingNumber() {
                // if new active building different from current active building
                if findVisibleBuildingNumber() == nil {
                    // no building on the screen
                    active = nil
                } else {
                    // changing building
                    active = Active(buildingNumber: findVisibleBuildingNumber()!, floor: 1)
                }
            }
        }
    }
    
    func focusCameraOn(classroom: String, inBuilding building: Int) {
        active? = Active(buildingNumber: building, classroom: classroom)
        moveCameraToActiveClassroom()
    }
    
    func focusCameraOn(building: Int) {
        active? = Active(buildingNumber: building, floor: 1)
        moveCameraToActiveBuilding()
    }
    
    func prepareForStoppingIndoor() {
        delegate!.mapView.clear()
        deleteButtons()
        deleteLabel()
    }
    
    // MARK: - private methods
    
    private func findVisibleBuildingNumber() -> Int? {
        let visibleRegion = delegate!.mapView.projection.visibleRegion()
        let regionRect = makeCGRect(fromRegion: visibleRegion)
        
        var maxRectArea: Float = 0
        var activeBuildingNumber: Int?
        
        for building in Database.allBuildings {
            let buildingRect = makeCGRect(fromCoordinateBounds: building.coordinateBounds)
            
            if regionRect.intersects(buildingRect) {
                let commonRect = regionRect.intersection(buildingRect)
                
                let areaOfCommonRect = areaOfRect(commonRect)
                if areaOfCommonRect > maxRectArea {
                    maxRectArea = areaOfCommonRect
                    activeBuildingNumber = building.number
                }
            } 
            
        }
        
        if activeBuildingNumber != nil {
            return activeBuildingNumber
        } else {
            return nil
        }
        
    }
    
    // MARK: - rects
    private func makeCGRect(fromRegion region: GMSVisibleRegion) -> CGRect {
        let x = Double(region.farLeft.longitude)
        let y = Double(region.farLeft.latitude)
        let width = Double(region.farRight.longitude) - x
        let height = Double(region.nearLeft.latitude) - y
        
        let result = CGRect(x: x, y: y, width: width, height: height)
        return result
    }
    
    private func makeCGRect(fromCoordinateBounds bounds: GMSCoordinateBounds) -> CGRect {
        let x = Double(bounds.southWest.longitude)
        let y = Double(bounds.northEast.latitude)
        let widht = Double(bounds.northEast.longitude) - x
        let height = Double(bounds.southWest.latitude) - y
        
        let result = CGRect(x: x, y: y, width: widht, height: height)
        return result
    }

    private func areaOfRect(_ rect: CGRect) -> Float {
        return Float(rect.width * rect.height)
    }
    
    // MARK: - Overlay's
    private func showBuildings() {
        for building in Database.allBuildings {
            let icon = UIImage(named: "\(building.number)-\(1)")
            
            let overlay = GMSGroundOverlay(bounds: building.coordinateBounds, icon: icon)
            overlay.map = delegate!.mapView
            overlays[building.number] = overlay
        }
    }
    
    private func updateActiveBuildingOverlay() {
        overlays[active!.building.number]!.icon = UIImage(named: "\(active!.building.number)-\(active!.floor)")
    }
    
    // MARK: - moving camera
    private func moveCameraToActiveClassroom() {
        delegate!.mapView.animate(toLocation: active!.classroomLocation!)
        delegate!.mapView.animate(toZoom: classroomZoom)
    }
    
    private func moveCameraToActiveBuilding() {
        delegate!.mapView.animate(toLocation: active!.buildingCenter)
        delegate!.mapView.animate(toZoom: buildingZoom)
    }
    
    // MARK: - floor butoons
    private func createButtonsForFloors() {
        let startX = -35
        let startY = Int(UIScreen.main.bounds.height - 60)
        let step = Int(#imageLiteral(resourceName: "button").size.height) + 3
        
        
        for floor in 1...active!.building.numberOfFloors {
            createButton(withText: String(floor), atPosition: CGPoint(x: startX, y: startY - step * floor))
        }
        
        findButtonWithName(active!.floor)!.center.x += 20
    }
    
    private func createButton(withText text: String, atPosition position: CGPoint) {
        let image = UIImage(named: "button")
        let button = UIButton(frame: CGRect(x: position.x, y: position.y, width: image!.size.width, height: image!.size.height))
        button.setBackgroundImage(image, for: .normal)
        button.setTitle("\(text)"+"\t", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = UIFont(name: "System-Bold", size: 20)
        button.contentHorizontalAlignment = .right
        button.alpha = 0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        delegate!.mapView.addSubview(button)
        
        floorButtons.append(button)
    }
    
    private func showButtons() {
        for button in floorButtons {
            button.alpha = CGFloat(1)
        }
    }
    
    private func updateButtons(newActive: Int) {
        let oldSelectedButton = findButtonWithName(active!.floor)!
        let newSelectedButton = findButtonWithName(newActive)!
        newSelectedButton.center.x += 20
        oldSelectedButton.center.x -= 20
    }
    
    private func redrawButtons() {
        for button in floorButtons {
            button.removeFromSuperview()
        }
        floorButtons.removeAll()
        createButtonsForFloors()
        for button in floorButtons {
            button.alpha = 1
        }
    }
    
    private func deleteButtons() {
        for button in self.floorButtons {
            button.alpha = 0
            button.removeFromSuperview()
        }
        floorButtons.removeAll()
    }
    
    private func findButtonWithName(_ name: Int) -> UIButton? {
        for button in floorButtons where button.currentTitle!.contains(String(name)) {
            return button
        }
        return nil
    }
    
    @objc func buttonTapped(button: UIButton) {
        let newActiveFloor = Int(String(button.currentTitle!.first!))!
        updateButtons(newActive: newActiveFloor)
        active!.floor = newActiveFloor
        updateActiveBuildingOverlay()
        updateLabel()
    }
    
    // MARK: - infoLabel
    private func createLabel() {
        let width = delegate!.mapView.bounds.width
        var navAndStatusBar: CGFloat {
            guard let vc = (delegate as? UIViewController),
                let navBar = vc.navigationController?.navigationBar else { return 64 }
            return navBar.bounds.height + UIApplication.shared.statusBarFrame.size.height
        }
        infoLabel = UILabel(frame: CGRect(x: 0, y: navAndStatusBar, width: width, height: 30))
        infoLabel.backgroundColor = .gray
        infoLabel.layer.masksToBounds = false
        infoLabel.layer.shadowOffset = CGSize(width: -5, height: 0)
        infoLabel.layer.shadowRadius = 10
        infoLabel.layer.shadowOpacity = 0.5
        updateLabel()
        infoLabel.textAlignment = .center
        delegate!.mapView.addSubview(infoLabel)
    }
    
    private func updateLabel() {
        if active!.classroom != nil {
            if active!.floor != active?.building.getClassroomWith(number: active!.classroom!)?.floor {
                infoLabel.text = active!.building.name
            } else {
                infoLabel.text = active!.classroomName
            }
        } else {
            infoLabel.text = active!.building.name
        }
    }
    
    private func deleteLabel() {
        infoLabel?.removeFromSuperview()
        infoLabel = nil
    }
    
    // MARK: - just for moving overlay
    
//    var marker1: GMSMarker!
//    var marker2: GMSMarker!
//    
//    func createMarkers() {
//        marker1 = GMSMarker(position: active.building.northEast)
//        marker1.isDraggable = true
//        marker1.title = "northEast"
//        
//        marker2 = GMSMarker(position: active.building.southWest)
//        marker2.isDraggable = true
//        marker2.title = "southWest"
//        
//        marker1.map = delegate!.mapView
//        marker2.map = delegate!.mapView
//    }
    
//    func createButtons() {
//        let redrawButton = UIButton(frame: CGRect(x: 50, y: 80, width: 70, height: 30))
//        redrawButton.setTitle("redraw", for: .normal)
//        redrawButton.setTitleColor(.black, for: .normal)
//        redrawButton.titleLabel!.font = UIFont(name: "System-Bold", size: 20)
//        redrawButton.addTarget(self, action: #selector(redrawTapped), for: .touchUpInside)
//        
//        delegate!.mapView.addSubview(redrawButton)
//    }
//    
//    func redrawTapped() {
//        overlay?.map = nil
//        
//        let icon = UIImage(named: "18-\(active!.floor)")
//        
//        let bounds = GMSCoordinateBounds(coordinate: marker2.position, coordinate: marker1.position)
//        
//        overlay = GMSGroundOverlay(bounds: bounds, icon: icon)
//        overlay.map = delegate!.mapView
//        
//        print("redrawed overlay at bounds northEast = \(bounds.northEast), southWest = \(bounds.southWest)")
//    }
//
    
    // for testing rects
//    
//    func createMarkers(rect: CGRect) {
//        createMarker(withName: "TopLeft", x: rect.minX, y: rect.minY)
//        createMarker(withName: "bottomLeft", x: rect.minX, y: rect.maxY)
//        createMarker(withName: "TopRight", x: rect.maxX, y: rect.minY)
//        createMarker(withName: "bottomRight", x: rect.maxX, y: rect.maxY)
//    }
//    
//    func createMarker(withName name: String, x: CGFloat, y: CGFloat) {
//        let latitude = CLLocationDegrees(y)
//        let longitude = CLLocationDegrees(x)
//        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//        marker.isDraggable = false
//        marker.title = name
//        marker.map = delegate!.mapView
//    }
    
}
