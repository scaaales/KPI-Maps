//
//  AppDelegate.swift
//  KPI Maps
//
//  Created by scales on 13.05.17.
//  Copyright © 2017 kpi. All rights reserved.
//

import GoogleMaps
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDoLMpavpI_9YcIWqtSt2A_yNLledXcVmk")
        Database.open()
        return true
    }

}

