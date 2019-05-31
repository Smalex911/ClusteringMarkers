//
//  MapDataAdapter.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 31/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapKit
import ClusteringMarkers

class MapDataAdapter: AbstractMapDataAdapter {
    
    override func initiatePin(object: AnyHashable) -> Pin? {
        if let store = object as? Store {
            return StorePin(store)
        }
        return nil
    }
    
    override func initiateCluster(coordinates: YMKPoint) -> Cluster {
        return StoreCluster(coordinate: coordinates)
    }
    
}
