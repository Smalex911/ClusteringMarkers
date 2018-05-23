//
//  MapKitAdapter.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit
import YandexMapKit

public extension YMKVisibleRegion {
    
    func getNorthEast(withZoomScale zoomScale: Float) -> YMKPoint {
        let size = ZoomLevel.cellSize(zoom: zoomScale)
        
        let swZoom = getSouthWest(withZoomScale: zoomScale)
        
        let maxX = swZoom.latitude + ((self.NorthEast.latitude - swZoom.latitude) / size).rounded(.up) * size
        let maxY = swZoom.longitude + ((self.NorthEast.longitude - swZoom.longitude) / size).rounded(.up) * size
        
        return YMKPoint(latitude: maxX, longitude: maxY)
    }
    
    func getSouthWest(withZoomScale zoomScale: Float) -> YMKPoint {
        let size = ZoomLevel.cellSize(zoom: zoomScale)
        
        let minX = (self.SouthWest.latitude / size).rounded(.down) * size
        let minY =  (self.SouthWest.longitude / size).rounded(.down) * size
        
        return YMKPoint(latitude: minX, longitude: minY)
    }
    
    func isInVisibleRegion(point: YMKPoint, zoom: Float) -> Bool {
        return point.latitude > getSouthWest(withZoomScale: zoom).latitude
            && point.latitude < getNorthEast(withZoomScale: zoom).latitude
            && point.longitude > getSouthWest(withZoomScale: zoom).longitude
            && point.longitude < getNorthEast(withZoomScale: zoom).longitude
    }
    
    var NorthEast : YMKPoint {
        return YMKPoint(latitude: MaxLatitude, longitude: MaxLongitude)
    }
    
    var SouthWest : YMKPoint {
        return YMKPoint(latitude: MinLatitude, longitude: MinLongitude)
    }
    
    var MaxLatitude : Double {
        return EdgeLatitudes.max() ?? 90
    }
    var MaxLongitude : Double {
        return EdgeLongitudes.max() ?? 180
    }
    var MinLatitude : Double {
        return EdgeLatitudes.min() ?? -90
    }
    var MinLongitude : Double {
        return EdgeLongitudes.min() ?? -180
    }
    
    var EdgeLatitudes : [Double] {
        return [self.bottomLeft.latitude, self.bottomRight.latitude,
                    self.topLeft.latitude, self.topRight.latitude]
    }
    var EdgeLongitudes : [Double] {
        return [self.bottomLeft.longitude, self.bottomRight.longitude,
                    self.topLeft.longitude, self.topRight.longitude]
    }
}
