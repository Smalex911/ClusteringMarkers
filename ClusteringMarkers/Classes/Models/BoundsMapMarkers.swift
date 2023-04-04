//
//  BoundsMapMarkers.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit
import YandexMapKit

public class BoundsMapMarkers {
    
    private var azimuthRad: Double = 0
    private var azimuthInvertedRad: Double = 0
    
    private var northPoz: Double = -90
    private var southPoz: Double = 90
    private var eastPoz: Double = -180
    private var westPoz: Double = 180
    
    public init(azimuth: Double = 0) {
        self.azimuthRad = deg2rad(azimuth)
        self.azimuthInvertedRad = deg2rad(0 - azimuth)
    }
    
    public func addPoint(point: YMKPoint) {
        let (lat, lng) = convertPoint(lat: point.latitude, lng: point.longitude, rad: azimuthRad)
        
        if (lat > northPoz) {
            northPoz = lat
        }
        if (lat < southPoz) {
            southPoz = lat
        }
        if (lng > eastPoz) {
            eastPoz = lng
        }
        if (lng < westPoz) {
            westPoz = lng
        }
    }
    
    public func getBoundingBox() -> YMKBoundingBox {
        let p1 = convertPoint(lat: southPoz, lng: westPoz, rad: azimuthInvertedRad)
        let p2 = convertPoint(lat: northPoz, lng: eastPoz, rad: azimuthInvertedRad)
        
        let lat = [p1.0, p2.0].sorted()
        let lng = [p1.1, p2.1].sorted()
        
        return YMKBoundingBox(
            southWest: YMKPoint(latitude: lat[0], longitude: lng[0]),
            northEast: YMKPoint(latitude: lat[1], longitude: lng[1]))
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func convertPoint(lat: Double, lng: Double, rad: Double) -> (Double, Double) {
        guard azimuthRad != 0 else {
            return (lat, lng)
        }
        return (
            lng * sin(rad) + lat * cos(rad),
            lng * cos(rad) - lat * sin(rad)
        )
    }
}
