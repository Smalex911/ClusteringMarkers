//
//  MapViewController.swift
//  ExampleClusteringMarkers
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapsMobile
import ClusteringMarkers

class MapViewController: UIViewController {

    @IBOutlet var viewContainer: UIView!
    
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
        
        mapDataAdapter = MapDataAdapter(delegate: self)
        if let v = mapDataAdapter?.mapView {
            viewContainer.addSubview(v)
            
            v.translatesAutoresizingMaskIntoConstraints = false
            
            viewContainer.addConstraints([
                NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: viewContainer, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: v, attribute: .left, relatedBy: .equal, toItem: viewContainer, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: viewContainer, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: v, attribute: .right, relatedBy: .equal, toItem: viewContainer, attribute: .right, multiplier: 1, constant: 0)
            ])
        }
        
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
    
    func onMapTap() {
        print("onMapTap")
    }
    
    func onMapLongTap() {
        print("onMapLongTap")
    }
    
    func willBeginScrollingMap(_ gesture: Bool) {
        print("willBeginScrollingMap")
    }
    
    func didEndScrollingMap(_ gesture: Bool) {
        print("didEndScrollingMap")
    }
}
