//
//  Marker.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit
import YandexMapKit

open class Marker: Hashable {
    
    public init() { }
    
    public static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        Coordinate.latitude.hash(into: &hasher)
        Coordinate.longitude.hash(into: &hasher)
    }
    
    open var Placemark: YMKPlacemarkMapObject? {
        didSet {
            setIcon()
        }
    }
    
    public var isValid: Bool {
        return Placemark?.isValid ?? true
    }
    
    open var isVisible: Bool {
        return Placemark?.isVisible ?? true
    }
    
    open var Coordinate: YMKPoint {
        return Placemark?.geometry ?? YMKPoint(latitude: 0, longitude: 0)
    }
    
    public func isEqual(placemark: YMKPlacemarkMapObject?) -> Bool {
        guard let pl = Placemark, pl.isValid, let placemark = placemark, placemark.isValid else {
            return false
        }
        return pl.geometry.latitude == placemark.geometry.latitude
            && pl.geometry.longitude == placemark.geometry.longitude
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
