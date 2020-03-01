//
//  Store.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 31/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import ClusteringMarkers

public class Store: Hashable, IPinObject {
    
    public static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        pinLatitude.hash(into: &hasher)
        pinLongitude.hash(into: &hasher)
    }
    
    public var pinLatitude: Double?
    public var pinLongitude: Double?
    
    init(latitude: Double, longitude: Double) {
        self.pinLatitude = latitude
        self.pinLongitude = longitude
    }
    
    public func isEqual(_ object: Any?) -> Bool {
        return self == (object as? Store)
    }
}
