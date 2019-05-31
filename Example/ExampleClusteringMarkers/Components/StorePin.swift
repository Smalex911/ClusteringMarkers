//
//  StorePin.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import YandexMapKit
import ClusteringMarkers

public class StorePin : Pin {
    
    var store: Store? {
        return object as? Store
    }
    
    override public var Coordinate: YMKPoint {
        return YMKPoint(
            latitude: store?.latitude ?? 0,
            longitude: store?.longitude ?? 0)
    }
    
    override public var Icon: UIImage? {
        return #imageLiteral(resourceName: "mapPin")
    }
    
    override public var SelectedIcon: UIImage? {
        return #imageLiteral(resourceName: "mapPin-selected")
    }
    
    override public func setIcon() {
        if let icon = IsSelected ? SelectedIcon : Icon {
            Placemark?.setIconWith(icon)
        }
    }
}
