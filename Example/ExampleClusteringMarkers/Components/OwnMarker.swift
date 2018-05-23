//
//  OwnMarker.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import YandexMapKit
import ClusteringMarkers

public class OwnMarker : Marker {
    
    override public var Coordinate: YMKPoint {
        return Point
    }
    
    var Point: YMKPoint
    
    init(point: YMKPoint) {
        self.Point = point
        super.init()
    }
    
    override public var Icon: UIImage? {
        return #imageLiteral(resourceName: "mapPin")
    }
    
    override public var SelectedIcon: UIImage? {
        return #imageLiteral(resourceName: "mapPin-selected")
    }
    
    override public func setIcon() {
        Placemark?.setIconWith(IsSelected ? SelectedIcon : Icon)
    }
}
