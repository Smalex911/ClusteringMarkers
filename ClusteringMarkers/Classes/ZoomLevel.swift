//
//  ZoomLevel.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit
import YandexMapKit

public class ZoomLevel {
    
    public static var DEFAULT_CELL_SIZE : Double = 12
    public static var DEFAULT_ZOOM : Float = 1
    public static var DEFAULT_CAMERA_ZOOM : Float = 16
    
    /**
     The dictionary of zoom and cell size.
     - Important:
     The size is calculated from 0 or the previous key to current.
    */
    open static var gradationZoom: [Float: Double] = [
        2 : 12,
        4.5 : 6,
        7 : 4.5,
        8.5 : 1.5,
        9.5 : 42.0 / 100.0,
        10 : 21.0 / 100.0,
        10.5 : 14.0 / 100.0,
        11.5 : 7.0 / 100.0,
        12.5 : 1.0 / 40.0,
        13 : 1.0 / 80.0,
        13.5 : 1.0 / 100.0,
        14 : 1.0 / 200.0,
        14.5 : 3.0 / 1000.0,
        15 : 2.0 / 1000.0,
        15.5 : 1.0 / 500.0,
        16 : 1.0 / 1000.0,
        Float.infinity : 1.0 / 5000.0,
    ]
    
    public static var maxZoom : Float {
        get {
            return gradationZoom.keys.filter({$0 != Float.infinity}).sorted(by: {$0 > $1}).first ?? Float.infinity
        }
    }
    
    static func cellSize(zoom: Float) -> Double {
        if let key = gradationZoom.keys.sorted().first(where: {$0 > zoom}) {
            return gradationZoom[key] ?? DEFAULT_CELL_SIZE
        }
        return DEFAULT_CELL_SIZE
    }
    
    public static func canZoomInCluster(currentZoom: Float, boundsZoom: Float) -> Bool {
        let newCurrentZoom = getMoreThan(zoom: currentZoom)
        let newBoundsZoom = getMoreThan(zoom: boundsZoom)
        
        return newBoundsZoom > newCurrentZoom
    }
    
    public static func zoomMoreThan(currentZoom: Float) -> Float {
        return getMoreThan(zoom: getMoreThan(zoom: currentZoom) + 0.001)
    }
    
    public static func zoomInCluster(boundsZoom: Float) -> Float {
        if (boundsZoom > maxZoom) {
            return maxZoom
        }
        return boundsZoom
    }
    
    public static func isDifferentZoom(lastZoom: Float, currentZoom: Float) -> Bool {
        return getMoreThan(zoom: lastZoom) != getMoreThan(zoom: currentZoom)
    }
    
    private static func getMoreThan(zoom: Float) -> Float {
        return gradationZoom.keys.sorted().first(where: {$0 > zoom}) ?? DEFAULT_ZOOM
    }
}
