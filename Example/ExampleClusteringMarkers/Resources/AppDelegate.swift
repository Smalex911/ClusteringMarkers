//
//  AppDelegate.swift
//  ExampleClusteringMarkers
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapKit
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        YMKMapKit.setApiKey("YOUR_API_KEY_HERE")
        return true
    }
}

