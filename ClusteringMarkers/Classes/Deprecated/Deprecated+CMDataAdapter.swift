//
//  Deprecated+CMDataAdapter.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 28.02.2020.
//

import YandexMapKit

extension CMDataAdapter {
    
    @available(*, deprecated, renamed: "move(zoomDiff:)")
    public func zoomIn() {
        move(zoomDiff: 1)
    }
    
    @available(*, deprecated, renamed: "move(zoomDiff:)")
    public func zoomOut() {
        move(zoomDiff: -1)
    }
    
    @available(*, deprecated, renamed: "select(with:)")
    public func selectOnMap(placemark: YMKPlacemarkMapObject?) {
        select(with: placemark)
    }
    
    @available(*, deprecated, renamed: "select(with:)")
    public func selectOnMap(object: IPinObject, fast: Bool = false) {
        select(with: object, targetZoom: pinTargetCameraZoom, animation: fast ? .immediate : .smooth)
    }
    
    @available(*, deprecated, renamed: "setMarkers(with:)")
    public func setMarkers(objects: [IPinObject]) {
        setMarkers(with: objects, withMoveToBounds: true)
    }
    
    @available(*, deprecated, renamed: "select(object:targetZoom:fast:)")
    public func select(with object: IPinObject, targetZoom: Float? = nil, animation: ScrollAnimation = .smooth) {
        select(object: object, targetZoom: targetZoom, animation: animation)
    }
    
    @available(*, deprecated, renamed: "select(placemark:)")
    public func select(with placemark: YMKPlacemarkMapObject?) {
        select(placemark: placemark)
    }
}
