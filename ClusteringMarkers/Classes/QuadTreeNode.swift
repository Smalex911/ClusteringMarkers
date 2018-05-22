//
//  FBQuadTreeNode.swift
//  saas-ios
//
//  Created by Александр Смородов on 03.05.2018.
//  Copyright © 2018 Nikita Zhukov. All rights reserved.
//

import YandexMapKit

open class QuadTreeNode {
    
    static let NodeCapacity = 8
    
    let boundingBox: BoundingBox
    private(set) var markers: [Marker] = []
    
    private(set) var northEast: QuadTreeNode?
    private(set) var northWest: QuadTreeNode?
    private(set) var southEast: QuadTreeNode?
    private(set) var southWest: QuadTreeNode?
    
    // MARK: - Initializers
    
    init() {
        boundingBox = BoundingBox()
    }
    
    init(boundingBox box: BoundingBox) {
        boundingBox = box
    }
    
    // MARK: - Instance functions
    
    func canAppendMarker() -> Bool {
        return markers.count < QuadTreeNode.NodeCapacity
    }
    
    func append(marker: Marker) -> Bool {
        if canAppendMarker() {
            markers.append(marker)
            return true
        }
        return false
    }
    
    func isLeaf() -> Bool {
        return (northEast == nil) ? true : false
    }
    
    func siblings() -> (northEast: QuadTreeNode, northWest: QuadTreeNode, southEast: QuadTreeNode, southWest: QuadTreeNode)? {
        if let northEast = northEast,
            let northWest = northWest,
            let southEast = southEast,
            let southWest = southWest {
            return (northEast, northWest, southEast, southWest)
        } else {
            return nil
        }
    }
    
    func createSiblings() -> (northEast: QuadTreeNode, northWest: QuadTreeNode, southEast: QuadTreeNode, southWest: QuadTreeNode) {
        let box = boundingBox
        northEast = QuadTreeNode(boundingBox: BoundingBox(x0: box.xMid, y0: box.y0, xf: box.xf, yf: box.yMid))
        northWest = QuadTreeNode(boundingBox: BoundingBox(x0: box.x0, y0: box.y0, xf: box.xMid, yf: box.yMid))
        southEast = QuadTreeNode(boundingBox: BoundingBox(x0: box.xMid, y0: box.yMid, xf: box.xf, yf: box.yf))
        southWest = QuadTreeNode(boundingBox: BoundingBox(x0: box.x0, y0: box.yMid, xf: box.xMid, yf: box.yf))
        
        return (northEast!, northWest!, southEast!, southWest!)
    }
    
}
