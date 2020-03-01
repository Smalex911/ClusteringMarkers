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
        latitude.hash(into: &hasher)
        longitude.hash(into: &hasher)
    }
    
    public var latitude: Double?
    public var longitude: Double?
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func isEqual(to object: IPinObject?) -> Bool {
        return self == (object as? Store)
    }
}
