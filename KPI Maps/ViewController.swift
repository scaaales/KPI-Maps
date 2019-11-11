//
//  ViewController.swift
//  KPI Maps
//
//  Created by scales on 13.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import GoogleMaps
import GRDB

class ViewController: UIViewController, GMSMapViewDelegate,  UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, IndoorViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - properties
    
    var results: [String] = [] // for search results
    var searchController: UISearchController!
    var resultController: UITableViewController!
    
    var indoorViewController: IndoorViewController!
    
    lazy var mapView: GMSMapView = { // main mapView initialization
        let camera = GMSCameraPosition.camera(withTarget: startLocation, zoom: defaultZoom)
        let mv = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mv.delegate = self
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mv.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        return mv
    }()
        
    var currentZoom: Float = 0 { // zoom analizing
        didSet {            
            if currentZoom > 18 {
                if indoorViewController == nil {
                    startIndoorMapping()
                } else {
                    indoorViewController.updateActiveBuilding()
                }
            } else {
                if oldValue > currentZoom {
                // zoomingOut
                    indoorViewController?.prepareForStoppingIndoor()
                    indoorViewController = nil
                }
            }
        }
    }
    
    // MARK: - override's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = mapView
        createSearchController()        
    }
    
    // MARK: - searchCotroller
    // MARK: searchController creation
    func createSearchController() {
        resultController = UITableViewController(style: .plain)
        resultController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        resultController.tableView.dataSource = self
        resultController.tableView.delegate = self
        resultController.tableView.alpha = 0.8
        
        searchController = UISearchController(searchResultsController:  resultController)
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Введіть номер аудиторії або корпусу"
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        searchController.searchBar.keyboardType = .decimalPad
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
    }
    
    // MARK: results
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ResultCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = results[indexPath.row]
        
        return cell
    }

    // MARK: search result tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.dismiss(animated: true)
        
        let words = results[indexPath.row].components(separatedBy: CharacterSet(charactersIn: " "))
        if words.contains("аудиторія") {
            display(building: Int(words[0])!, andClassroom: words[2])
        } else {
            display(building: Int(words[0])!)
        }
    }
    
    // MARK: search text field changed
    func updateSearchResults(for searchController: UISearchController) {
        results.removeAll()
        
        
        if searchController.searchBar.text! != "" {
            let words = searchController.searchBar.text!.replacingOccurrences(of: ",", with: " ").components(separatedBy: " ")
            
            results = Database.allObjectsNames.filter { (element) -> Bool in
                for word in words {
                    if !element.contains(word) {
                        if word != "" {
                            return false
                        }
                    }
                }
                return true
            }
            
            resultController.tableView.reloadData()
        }
    }
    
    // MARK: - Indoor
    func startIndoorMapping() {
        indoorViewController = IndoorViewController()
        indoorViewController.delegate = self
        indoorViewController.startIndoor()
    }
    
    func display(building: Int, andClassroom classroom: String? = nil) {
        if indoorViewController == nil {
            startIndoorMapping()
        }
        if classroom == nil {
            indoorViewController.focusCameraOn(building: building)
        } else {
            indoorViewController.focusCameraOn(classroom: classroom!, inBuilding: building)
        }
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        currentZoom = mapView.camera.zoom
    }
    
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("\(indoorViewController.active!.building.number)\t\(indoorViewController.active!.floor)\t\(coordinate.latitude)\t\(coordinate.longitude)")
//    }
}


