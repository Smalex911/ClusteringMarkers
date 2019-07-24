//
//  AbstractMapDataAdapter.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import YandexMapKit

open class AbstractMapDataAdapter: NSObject, YMKMapObjectTapListener, YMKMapInputListener, YMKMapCameraListener, YMKUserLocationObjectListener {
    
    public weak var delegate: MapDataDelegate?
    
    public var mapView: YMKMapView?
    
    var map: YMKMap? {
        return mapView?.mapWindow.map
    }
    
    public var zoomLevel = ZoomLevel()
    
    var pins: [Pin] = []
    var clusters: [Cluster] = []
    
    var clusteringManager: ClusteringManager?
    
    func initClusteringManager() {
        clusteringManager = ClusteringManager(initiateCluster: { (coordinates) in
            return self.initiateCluster(coordinates: coordinates)
        })
        clusteringManager?.zoomLevel = zoomLevel
    }
    
    var didFirstScroll = false
    
    var selectedPin: Pin? {
        didSet {
            if oldValue != selectedPin && (oldValue?.isValid ?? false) {
                oldValue?.IsSelected = false
            }
        }
    }
    
    func setSelectedPin(_ pin: Pin?, needNotificate: Bool = true) {
        if selectedPin != pin {
            selectedPin = pin
            
            if needNotificate {
                delegate?.didSelectPin(selectedPin)
            }
        } else if !(selectedPin?.isValid ?? true) {
            selectedPin = pin
        }
    }
    
    var lastZoom: Float = 0
    
    open func initiatePin(object: AnyHashable) -> Pin? {
        return Pin(object)
    }
    
    open func initiateCluster(coordinates: YMKPoint) -> Cluster {
        return Cluster(coordinate: coordinates)
    }
    
    var lastSettingMarkersWork: DispatchWorkItem?
    
    var isNewMarkers: Bool = true
    open func setMarkers(objects: [AnyHashable]) {
        
        if let selectedMarker = selectedPin, !objects.contains(where: {$0 == selectedMarker.object}) {
            setSelectedPin(nil)
        }
        
        isNewMarkers = true
        
        if objects.count != 0 {
            
            if !(lastSettingMarkersWork?.isCancelled ?? true) {
                lastSettingMarkersWork?.cancel()
            }
            let zoomLevel = self.zoomLevel
            
            var work: DispatchWorkItem!
            work = DispatchWorkItem { [weak self] in
                let clusteringManager = self?.clusteringManager
                
                var pins: [Pin] = []
                let bounds = BoundsMapMarkers()
                
                objects.forEach { (object: AnyHashable) in
                    if let pin = self?.initiatePin(object: object) {
                        pins.append(pin)
                        bounds.addPoint(point: pin.Coordinate)
                    }
                }
                clusteringManager?.replace(markers: pins)
                pins.forEach({$0.Placemark = nil})
                
                if !work.isCancelled {
                    DispatchQueue.main.sync { [weak self] in
                        
                        guard let _self = self else {
                            return
                        }
                        
                        _self.map?.mapObjects.clear()
                        _self.pins = pins
                        _self.clusters.removeAll()
                        
                        if let map = _self.mapView?.mapWindow.map {
                            if let userLocation = _self.userLocation {
                                bounds.addPoint(point: userLocation)
                            }
                            
                            let cameraPosition = map.cameraPosition(with: bounds.getBoundingBox())
                            
                            var zoom = cameraPosition.zoom - 0.2
                            if (zoom > zoomLevel.maxZoom) {
                                zoom = zoomLevel.maxZoom
                            }
                            _self.move(target: cameraPosition.target, zoom: zoom, fast: true)
                        } else {
                            _self.updateMarkersInThread(afterSetMarkers: true)
                        }
                    }
                }
            }
            lastSettingMarkersWork = work
            delegate?.willBeginUpdateMarkers()
            DispatchQueue.global(qos: .userInteractive).async(execute: work)
        } else {
            cleanMarkers()
        }
    }
    
    open var userLocation: YMKPoint? {
        get {
            if let target = mapView?.mapWindow.map.userLocationLayer.cameraPosition()?.target {
                return target
            }
            return nil
        }
    }
    
    func cleanMarkers() {
        didFirstScroll = false
        
        map?.mapObjects.clear()
        clusteringManager?.removeAll()
        
        pins.forEach({$0.Placemark = nil})
        pins.removeAll()
        
        clusters.forEach({$0.Placemark = nil})
        clusters.removeAll()
        
        updateMarkersInThread(afterSetMarkers: true)
    }
    
    enum ClusterUpdatingType {
        case needRemove
        case needAdd
        case doNothing
    }
    
    var lastUpdatingMarkersWork: DispatchWorkItem?
    
    func updateMarkersInThread(afterSetMarkers: Bool) {
        if !(lastUpdatingMarkersWork?.isCancelled ?? true) {
            lastUpdatingMarkersWork?.cancel()
        }
        guard let visibleRegion = mapView?.mapWindow.focusRegion else {
            return
        }
        let currentZoom = map?.cameraPosition.zoom
        let lastZoom = self.lastZoom
        let zoomLevel = self.zoomLevel
        
        var work: DispatchWorkItem!
        work = DispatchWorkItem { [weak self] in
            
            guard let _self = self, let clusteringManager = _self.clusteringManager else {
                return
            }
            
            let pins = _self.pins
            var dictChangingPins: [YMKPoint: (Bool, Pin)] = [:]
            var dictChangingClusters: [Cluster: ClusterUpdatingType] = [:]
            var needAllClean = false
            
            let clusteredPlacemarks = clusteringManager.clusteredMarkers(
                withinVisibleRegion: visibleRegion,
                zoomScale: currentZoom ?? zoomLevel.defaultZoom)
            
            if let currentZoom = currentZoom {
                
                if zoomLevel.isDifferentZoom(lastZoom: lastZoom, currentZoom: currentZoom) {
                    needAllClean = true
                    pins.forEach { $0.Placemark = nil }
                } else {
                    
                    for pin in _self.pins {
                        if pin.Placemark != nil, !visibleRegion.isInVisibleRegion(zoomLevel: zoomLevel, point: pin.Coordinate, zoom: currentZoom) {
                            dictChangingPins[pin.Coordinate] = (true, pin)
                        }
                    }
                    for cluster in _self.clusters {
                        if cluster.Placemark != nil, !visibleRegion.isInVisibleRegion(zoomLevel: zoomLevel, point: cluster.Coordinate, zoom: currentZoom) {
                            dictChangingClusters[cluster] = .needRemove
                        } else {
                            dictChangingClusters[cluster] = .doNothing
                        }
                    }
                }
            }
            
            for marker in clusteredPlacemarks {
                if needAllClean || marker.Placemark == nil {
                    if let pin = marker as? Pin {
                        dictChangingPins[pin.Coordinate] = (false, pin)
                    } else if let cluster = marker as? Cluster {
                        if dictChangingClusters[cluster] != .doNothing {
                            dictChangingClusters[cluster] = .needAdd
                        }
                    }
                }
            }
            
            if !work.isCancelled {
                DispatchQueue.main.sync { [weak self] in
                    
                    guard let _self = self else {
                        return
                    }
                    
                    if needAllClean {
                        _self.map?.mapObjects.clear()
                        _self.pins = pins
                        _self.clusters.removeAll()
                    }
                    
                    dictChangingPins.values.forEach({ (isNeedRemove, pin) in
                        if isNeedRemove {
                            if let placemark = pin.Placemark, placemark.isValid {
                                _self.map?.mapObjects.remove(with: placemark)
                            }
                            pin.Placemark = nil
                        } else {
                            if let placemark = _self.map?.mapObjects.addEmptyPlacemark(with: pin.Coordinate) {
                                
                                if _self.selectedPin == pin && !pin.IsSelected {
                                    pin.IsSelected = true
                                    
                                    _self.setSelectedPin(pin)
                                }
                                pin.Placemark = placemark
                                placemark.addTapListener(with: _self)
                            }
                        }
                    })
                    
                    dictChangingClusters.forEach({ (cluster, type) in
                        switch type {
                        case .needRemove:
                            if let placemark = cluster.Placemark, placemark.isValid {
                                _self.map?.mapObjects.remove(with: placemark)
                            }
                            if let index = _self.clusters.firstIndex(of: cluster) {
                                _self.clusters.remove(at: index)
                            }
                            break
                        case .needAdd:
                            if let placemark = _self.map?.mapObjects.addEmptyPlacemark(with: cluster.Coordinate) {
                                
                                cluster.Placemark = placemark
                                placemark.addTapListener(with: _self)
                                _self.clusters.append(cluster)
                            }
                            break
                        case .doNothing:
                            break
                        }
                    })
                    
                    if _self.isNewMarkers {
                        _self.isNewMarkers = false
                        _self.delegate?.didEndUpdateMarkers(true)
                    } else {
                        _self.delegate?.didEndUpdateMarkers(false)
                    }
                }
            }
        }
        lastUpdatingMarkersWork = work
        delegate?.willBeginUpdateMarkers()
        DispatchQueue.global(qos: .userInteractive).async(execute: work)
    }
    
    public init(mapView: YMKMapView) {
        super.init()
        
        self.mapView = mapView
        initClusteringManager()
        initiateMapSettings()
    }
    
    public init(bounds: CGRect) {
        super.init()
        
        self.mapView = YMKMapView(frame: bounds)
        initClusteringManager()
        initiateMapSettings()
    }
    
    open func initiateMapSettings() {
        map?.addInputListener(with: self)
        map?.addCameraListener(with: self)
        map?.userLocationLayer.setObjectListenerWith(self)
        map?.logo.setAlignmentWith(YMKLogoAlignment(horizontalAlignment: .left, verticalAlignment: .bottom))
        map?.userLocationLayer.isEnabled = true
    }
    
    public func moveToCurrentLocation() {
        if let userLocation = userLocation {
            move(target: YMKPoint(latitude: userLocation.latitude, longitude: userLocation.longitude), zoom: zoomLevel.defaultUserLocationCameraZoom, fast: false)
        }
    }
    
    public func zoomIn() {
        if let map = map {
            move(target: map.cameraPosition.target, zoom: map.cameraPosition.zoom + 1)
        }
    }
    
    public func zoomOut() {
        if let map = map {
            move(target: map.cameraPosition.target, zoom: map.cameraPosition.zoom - 1)
        }
    }
    
    private func move(target: YMKPoint, zoom: Float, fast: Bool = false) {
        if let map = map {
            map.move(
                with: YMKCameraPosition(
                    target: target,
                    zoom: zoom,
                    azimuth: map.cameraPosition.azimuth,
                    tilt: map.cameraPosition.tilt),
                animationType: YMKAnimation(
                    type: fast ? .linear : .smooth,
                    duration: fast ? 0 : 0.2),
                cameraCallback: nil)
        }
    }
    
    
    public func setCityLocation(latitude: Double, longitude: Double) {
        if let map = map {
            map.move(
                with: YMKCameraPosition(
                    target: YMKPoint(latitude: latitude, longitude: longitude),
                    zoom: 8,
                    azimuth: map.cameraPosition.azimuth,
                    tilt: map.cameraPosition.tilt),
                animationType: YMKAnimation(
                    type: YMKAnimationType.linear,
                    duration: 0)) { (compleed) in
                        self.didFirstScroll = false
            }
        }
    }
    
    public func selectOnMap(object: AnyHashable, fast: Bool = false) {
        for pin in pins {
            if pin.object == object {
                unselectPin(newSelectedPin: pin, needNotificate: false)
                
                pin.IsSelected = true
                selectedPin = pin
                
                if let map = mapView?.mapWindow.map {
                    move(
                        target: pin.Coordinate,
                        zoom: map.cameraPosition.zoom >= zoomLevel.defaultCameraZoom
                            ? map.cameraPosition.zoom : zoomLevel.defaultCameraZoom,
                        fast: fast)
                }
                return
            }
        }
    }
    
    public func selectOnMap(placemark: YMKPlacemarkMapObject?) {
        
        if let _pl = placemark {
            if let newSelectedCluster = clusters.first(where: { $0.isEqual(placemark: _pl) }) {
                delegate?.didTapOnCluster()
                
                if let map = mapView?.mapWindow.map {
                    let cameraPosition = map.cameraPosition(with: newSelectedCluster.bounds)
                    let boundsZoom = cameraPosition.zoom - 0.2
                    
                    if zoomLevel.canZoomInCluster(currentZoom: map.cameraPosition.zoom, boundsZoom: boundsZoom) {
                        self.move(target: cameraPosition.target, zoom: zoomLevel.zoomInCluster(boundsZoom: boundsZoom))
                    } else {
                        self.move(target: newSelectedCluster.centerMarkers, zoom: zoomLevel.zoomMoreThan(currentZoom: map.cameraPosition.zoom))
                    }
                }
            } else if let newSelectedPin = pins.first(where: { $0.isEqual(placemark: _pl) }) {
                delegate?.didTapOnPin()
                
                newSelectedPin.IsSelected = true
                setSelectedPin(newSelectedPin)
            }
        } else {
            unselectPin(newSelectedPin: nil)
        }
    }
    
    private func unselectPin(newSelectedPin: Pin?, needNotificate: Bool = true) {
        if let selectedPin = pins.first(where: {$0.IsSelected})
        {
            if newSelectedPin == nil || newSelectedPin != selectedPin {
                setSelectedPin(nil, needNotificate: needNotificate)
                selectedPin.IsSelected = false
            }
        }
    }
    
    public func resetCamera() {
        map?.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: 0, longitude: 0),
                zoom: 0,
                azimuth: 0,
                tilt: 0),
            animationType: YMKAnimation(
                type: YMKAnimationType.linear,
                duration: 0),
            cameraCallback: nil)
    }
    
    public func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        
        if let _pl = mapObject as? YMKPlacemarkMapObject {
            selectOnMap(placemark: _pl)
        }
        return true
    }
    
    public func onMapTap(with map: YMKMap, point: YMKPoint) {
        selectOnMap(placemark: nil)
    }
    
    public func onMapLongTap(with map: YMKMap, point: YMKPoint) {
    }
    
    public func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
        didFirstScroll = true
        
        if finished {
            self.perform(#selector(updateMarkersAfterScroll), with: nil, afterDelay: 0.05)
        }
    }
    
    @objc func updateMarkersAfterScroll() {
        if let map = map {
            updateMarkersInThread(afterSetMarkers: false)
            lastZoom = map.cameraPosition.zoom
        }
    }
    
    open func onObjectAdded(with view: YMKUserLocationView) {
    }
    
    open func onObjectRemoved(with view: YMKUserLocationView) {
    }
    
    open func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {
    }
}
