//
//  FBQuadTree.swift
//  saas-ios
//
//  Created by Александр Смородов on 03.05.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

open class QuadTree {
    
    let rootNode: QuadTreeNode = QuadTreeNode()
    
    // MARK: Internal functions
    
    func insert(marker: Marker) -> Bool {
        return insert(marker: marker, toNode:rootNode)
    }
    
    func enumerateMarkers(inBox box: BoundingBox, callback: (Marker) -> Void) {
        enumerateMarkers(inBox: box, withNode:rootNode, callback: callback)
    }
    
    func enumerateMarkersUsingBlock(_ callback: (Marker) -> Void) {
        enumerateMarkers(inBox: BoundingBox(), withNode:rootNode, callback:callback)
    }
    
    // MARK: Private functions
    
    private func insert(marker: Marker, toNode node: QuadTreeNode) -> Bool {
        if !node.boundingBox.contains(coordinate: marker.Coordinate) {
            return false
        }
        
        if node.canAppendMarker() {
            return node.append(marker: marker)
        }
        
        let siblings = node.siblings() ?? node.createSiblings()
        
        if insert(marker: marker, toNode:siblings.northEast) {
            return true
        }
        
        if insert(marker: marker, toNode:siblings.northWest) {
            return true
        }
        
        if insert(marker: marker, toNode:siblings.southEast) {
            return true
        }
        
        if insert(marker: marker, toNode:siblings.southWest) {
            return true
        }
        
        return false
    }
    
    private func enumerateMarkers(inBox box: BoundingBox, withNode node: QuadTreeNode, callback: (Marker) -> Void) {
        if !node.boundingBox.intersects(box2: box) {
            return
        }
        
        for marker in node.markers {
            if box.contains(coordinate: marker.Coordinate) {
                callback(marker)
            }
        }
        
        if node.isLeaf() {
            return
        }
        
        if let northEast = node.northEast {
            enumerateMarkers(inBox: box, withNode: northEast, callback: callback)
        }
        
        if let northWest = node.northWest {
            enumerateMarkers(inBox: box, withNode: northWest, callback: callback)
        }
        
        if let southEast = node.southEast {
            enumerateMarkers(inBox: box, withNode: southEast, callback: callback)
        }
        
        if let southWest = node.southWest {
            enumerateMarkers(inBox: box, withNode: southWest, callback: callback)
        }
    }
}
