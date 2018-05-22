//
//  FBBoundingBox.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import YandexMapKit

struct BoundingBox {
    
    var x0, y0, xf, yf : Double
    
    init() {
        self.x0 = -90
        self.y0 = -180
        self.xf = 90
        self.yf = 180
    }
    
    init(x0: Double, y0: Double, xf: Double, yf: Double) {
        self.x0 = x0
        self.y0 = y0
        self.xf = xf
        self.yf = yf
    }
    
    var xMid: Double {
        return (xf + x0) / 2.0
    }
    
    var yMid: Double {
        return (yf + y0) / 2.0
    }
    
    func intersects(box2: BoundingBox) -> Bool {
        return (x0 <= box2.xf && xf >= box2.x0 && y0 <= box2.yf && yf >= box2.y0)
    }
    
    func contains(coordinate: YMKPoint) -> Bool {
        let containsX = (x0 <= coordinate.latitude) && (coordinate.latitude <= xf)
        let containsY = (y0 <= coordinate.longitude) && (coordinate.longitude <= yf)
        return (containsX && containsY)
    }
    
    func mapRect() -> YMKVisibleRegion {
        let topLeft = YMKPoint(latitude: x0, longitude: y0)
        let topRight = YMKPoint(latitude: x0, longitude: yf)
        let botLeft = YMKPoint(latitude: x0, longitude: yf)
        let botRight = YMKPoint(latitude: xf, longitude: yf)
        
        return YMKVisibleRegion(topLeft: topLeft, topRight: topRight, bottomLeft: botLeft, bottomRight: botRight)
    }
}

