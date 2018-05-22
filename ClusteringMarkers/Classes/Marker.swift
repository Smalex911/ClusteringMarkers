//
//  Marker.swift
//  saas-ios
//
//  Created by Александр Смородов on 04.05.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

open class Marker: Hashable {
    
    public init() { }
    
    open var hashValue: Int {
        return Coordinate.latitude.hashValue ^ Coordinate.longitude.hashValue
    }
    
    open static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    open var Placemark: YMKPlacemarkMapObject? {
        didSet {
            setIcon()
        }
    }
    
    open var Coordinate: YMKPoint {
        return Placemark?.geometry ?? YMKPoint(latitude: 0, longitude: 0)
    }
    
    open var IsSelected: Bool = false {
        didSet {
            setIcon()
        }
    }
    
    open var Icon : UIImage? {
        return nil
    }
    
    open var SelectedIcon : UIImage? {
        return nil
    }
    
    open func setIcon() { }
}
