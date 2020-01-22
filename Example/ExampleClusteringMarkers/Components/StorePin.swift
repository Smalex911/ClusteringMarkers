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
    
    override public func setIcon() {
        if Placemark != nil {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            view.isOpaque = false
            view.backgroundColor = IsSelected ? .black : .red
            view.layer.cornerRadius = 10
            
            Placemark?.setViewWithView(YRTViewProvider(uiView: view))
        }
    }
}
