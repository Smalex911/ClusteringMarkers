//
//  FBClusteringManager.swift
//  saas-ios
//
//  Created by Александр Смородов on 03.05.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

public class ClusteringManager<T:Cluster> {
    
    private var backingTree: QuadTree?
    private var tree: QuadTree? {
        set {
            backingTree = newValue
        }
        get {
            if backingTree == nil {
                backingTree = QuadTree()
            }
            return backingTree
        }
    }
    private let lock = NSRecursiveLock()
    
    public init() { }
    
    public init(markers: [Marker]) {
        add(markers: markers)
    }
    
    public func add(markers:[Marker]){
        lock.lock()
        for marker in markers {
            _ = tree?.insert(marker: marker)
        }
        lock.unlock()
    }
    
    public func removeAll() {
        tree = nil
    }
    
    public func replace(markers:[Marker]){
        removeAll()
        add(markers: markers)
    }
    
    public func allMarkers() -> [Marker] {
        var markers = [Marker]()
        lock.lock()
        tree?.enumerateMarkersUsingBlock(){ obj in
            markers.append(obj)
        }
        lock.unlock()
        return markers
    }
    
    public func clusteredMarkers(withinVisibleRegion region:YMKVisibleRegion, zoomScale: Float) -> [Marker] {
        
        let size = ZoomLevel.cellSize(zoom: zoomScale)
        
        let swZoom = region.getSouthWest(withZoomScale: zoomScale)
        let neZoom = region.getNorthEast(withZoomScale: zoomScale)
        
        let minX = swZoom.latitude
        let maxX = neZoom.latitude
        let minY = swZoom.longitude
        let maxY = neZoom.longitude
        
        var clusteredMarkers = [Marker]()
        
        lock.lock()
        
        if (zoomScale >= ZoomLevel.maxZoom) {
            let mapBox = BoundingBox(x0: minX, y0: minY, xf: maxX, yf: maxY)
            
            tree?.enumerateMarkers(inBox: mapBox) { obj in
                clusteredMarkers.append(obj)
            }
            
        } else {
            var x0 = minX
            var y0 = minY
            
            while x0 < maxX {
                while y0 < maxY {
                    
                    let mapBox = BoundingBox(x0: x0, y0: y0, xf: x0 + size, yf: y0 + size)
                    
                    var totalLatitude: Double = 0
                    var totalLongitude: Double = 0
                    
                    var markers = [Marker]()
                    
                    tree?.enumerateMarkers(inBox: mapBox) { obj in
                        totalLatitude += obj.Coordinate.latitude
                        totalLongitude += obj.Coordinate.longitude
                        markers.append(obj)
                    }
                    
                    let count = markers.count
                    
                    switch count {
                    case 0: break
                    case 1:
                        clusteredMarkers.append(contentsOf: markers)
                    default:
                        let coordinate = YMKPoint(
                            latitude: totalLatitude/Double(count),
                            longitude: totalLongitude/Double(count))
                        
                        let cluster = T(coordinate: coordinate)
                        cluster.markers = markers
                        clusteredMarkers.append(cluster)
                    }
                    
                    y0 += size
                }
                x0 += size
                y0 = minY
            }
        }
        
        lock.unlock()
        
        return clusteredMarkers
    }
}
