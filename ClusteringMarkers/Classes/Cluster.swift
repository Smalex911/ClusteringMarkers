//
//  FBAnnotationCluster.swift
//  saas-ios
//
//  Created by Александр Смородов on 03.05.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

open class Cluster : Marker {
    
    private var _coord : YMKPoint
    
    override open var Coordinate: YMKPoint {
        return _coord
    }
    
    open var displayedTitle: String {
        return "\(markers.count)"
    }
    
    open var number: Double {
        return Double(markers.count)
    }
    
    public var markers: [Marker] = []
    
    public var bounds: YMKBoundingBox {
        get {
            let b = BoundsMapMarkers()
            for marker in markers {
                b.addPoint(point: marker.Coordinate)
            }
            return b.getBoundingBox()
        }
    }
    
    public var centerMarkers: YMKPoint {
        get {
            if markers.count > 0 {
                var totalLatitude = 0.0
                var totalLongitude = 0.0
                
                for marker in markers {
                    totalLatitude += marker.Coordinate.latitude
                    totalLongitude += marker.Coordinate.longitude
                }
                
                return YMKPoint(latitude: totalLatitude / Double(markers.count), longitude: totalLongitude / Double(markers.count))
            } else {
                return YMKPoint(latitude: 0, longitude: 0)
            }
        }
    }
    
    required public init(coordinate: YMKPoint) {
        self._coord = coordinate
    }
    
    open override func setIcon() {
        Placemark?.setIconWith(ClusterViewConfiguration().getClusterImage(number: number, displayedText: displayedTitle))
    }
}
