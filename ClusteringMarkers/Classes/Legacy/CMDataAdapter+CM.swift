//
//  CMDataAdapter+CM.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 28.02.2020.
//

import YandexMapsMobile

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
        select(with: object, targetZoom: pinTargetCameraZoom, fast: fast)
    }
    
    @available(*, deprecated, renamed: "setMarkers(with:)")
    public func setMarkers(objects: [IPinObject]) {
        setMarkers(with: objects, withMoveToBounds: true)
    }
}
