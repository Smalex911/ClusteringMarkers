//
//  Store.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 31/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public class Store: Hashable {
    
    public static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        latitude.hash(into: &hasher)
        longitude.hash(into: &hasher)
    }
    
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
