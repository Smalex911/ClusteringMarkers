//
//  Ext+YMKPoint.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 23.10.2019.
//

import YandexMapKit
import CoreLocation

extension YMKPoint {
    
    func distance(to point: YMKPoint) -> Double? {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: point.latitude, longitude: point.longitude)
        
        return loc2.distance(from: loc1)
    }
    
    public var isZero: Bool {
        return latitude == 0 && longitude == 0
    }
}
