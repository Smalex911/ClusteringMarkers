//
//  IconStyle.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 28.02.2020.
//

import YandexMapKit

public typealias IconStyle = YMKIconStyle

extension IconStyle {
    
    /**
     - parameter anchor: An anchor is used to alter image placement. Normalized: (0.0f, 0.0f) denotes the top left image corner; (1.0f, 1.0f) denotes bottom right. `(0.5f, 0.5f)` by default.
     - parameter rotationType: Icon rotation type. `NoRotation` by default.
     - parameter zIndex: Z-index of the icon, relative to the placemark's z-index.
     - parameter flat: If true, the icon is displayed on the map surface. If false, the icon is displayed on the screen surface. `false` by default.
     - parameter visible: Sets icon visibility. `true` by default.
     - parameter scale: Scale of the icon. `1.0f` by default.
     - parameter tappableArea: Tappable area on the icon. Coordinates are measured the same way as anchor coordinates. If rect is empty or invalid, the icon will not process taps. `icons process all taps` by default.
     */
    public convenience init(anchor: CGPoint? = nil, rotationType: RotationType? = nil, zIndex: NSNumber? = nil, flat: NSNumber? = nil, visible: NSNumber? = nil, scale: NSNumber? = nil, tappableArea: YMKRect? = nil) {
        
        self.init(
        anchor: anchor as NSValue?,
        rotationType: rotationType?.rawValue as NSNumber?,
        zIndex: zIndex,
        flat: flat,
        visible: visible,
        scale: scale,
        tappableArea: tappableArea)
    }
    
    public typealias RotationType = YMKRotationType
}
