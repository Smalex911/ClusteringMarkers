//
//  BoundsMapMarkers.swift
//  saas-ios
//
//  Created by Александр Смородов on 28.04.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

public class BoundsMapMarkers {
    
    private var northPoz: Double = -90
    private var southPoz: Double = 90
    private var westPoz: Double = -180
    private var eastPoz: Double = 180
    
    public init() { }
    
    public func addPoint(point: YMKPoint) {
        if (point.latitude > northPoz) {
            northPoz = point.latitude
        }
        if (point.latitude < southPoz) {
            southPoz = point.latitude
        }
        if (point.longitude > westPoz) {
            westPoz = point.longitude
        }
        if (point.longitude < eastPoz) {
            eastPoz = point.longitude
        }
    }
    
    public func getBoundingBox() -> YMKBoundingBox {
        return YMKBoundingBox(
            southWest: YMKPoint(latitude: southPoz, longitude: westPoz),
            northEast: YMKPoint(latitude: northPoz, longitude: eastPoz))
    }
}
