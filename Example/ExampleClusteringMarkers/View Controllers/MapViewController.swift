//
//  MapViewController.swift
//  ExampleClusteringMarkers
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapKit
import ClusteringMarkers

class MapViewController: UIViewController {

    @IBOutlet var mapView: YMKMapView!
    
    var mapDataAdapter: MapDataAdapter?
    
    private let CLUSTER_CENTERS: [YMKPoint] = [
        YMKPoint(latitude: 55.756, longitude: 37.618),
//        YMKPoint(latitude: 59.956, longitude: 30.313),
//        YMKPoint(latitude: 56.838, longitude: 60.597),
//        YMKPoint(latitude: 43.117, longitude: 131.900),
//        YMKPoint(latitude: 56.852, longitude: 53.204)
    ]
    private let PLACEMARKS_NUMBER = 2000
    
    var placemarkCollection: YMKClusterizedPlacemarkCollection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapDataAdapter = MapDataAdapter(mapView: mapView, delegate: self)
        
        let stores = createStores()
        mapDataAdapter?.setMarkers(with: stores, withMoveToBounds: true)
    }

    func randomDouble() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }

    func createPoints() -> [YMKPoint] {
        var points = [YMKPoint]()
        for _ in 0..<PLACEMARKS_NUMBER {
            let clusterCenter = CLUSTER_CENTERS.randomElement()!
            let latitude = clusterCenter.latitude + randomDouble()  - 0.5
            let longitude = clusterCenter.longitude + randomDouble()  - 0.5

            points.append(YMKPoint(latitude: latitude, longitude: longitude))
        }

        return points
    }
    
    func createStores() -> [Store] {
        var points = [Store]()
        for _ in 0..<PLACEMARKS_NUMBER {
            let clusterCenter = CLUSTER_CENTERS.randomElement()!
            let latitude = clusterCenter.latitude + randomDouble()  - 0.5
            let longitude = clusterCenter.longitude + randomDouble()  - 0.5

            points.append(Store(latitude: latitude, longitude: longitude))
        }

        return points
    }
}

extension MapViewController: CMDelegate {
    
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didSelectPin pin: Pin?) {
        if let store = pin?.object as? Store {
            print("\(store.pinLatitude) \(store.pinLongitude)")
        } else {
            print("pin deselected")
        }
    }
}
