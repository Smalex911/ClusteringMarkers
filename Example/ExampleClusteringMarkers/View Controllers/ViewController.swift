//
//  ViewController.swift
//  ExampleClusteringMarkers
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapKit
import ClusteringMarkers

class ViewController: UIViewController {

    @IBOutlet var mapView: YMKMapView!
    
    var mapDataAdapter: MapDataAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapDataAdapter = MapDataAdapter(mapView: mapView)
        mapDataAdapter?.delegate = self
        
        var stores = [Store]()
        
        for lat in 1...50 {
            for lng in 1...50 {
                stores.append(Store(latitude: 56.0 + Double(lat) / 200,
                                    longitude: 59.0 + Double(lng) / 100)
                )
            }
        }
        
        mapDataAdapter?.setMarkers(objects: stores)
    }
}

extension ViewController: MapDataDelegate {
    
    func didSelectPin(_ pin: Pin?) {
        if let store = (pin as? StorePin)?.store {
            print("\(store.latitude) \(store.longitude)")
        } else {
            print("pin deselected")
        }
    }
    
    func didTapOnPin() {
        print("did tap on pin")
    }
    
    func didTapOnCluster() {
        print("did tap on cluster")
    }
}
