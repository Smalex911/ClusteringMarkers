//
//  AbstractMapDataAdapter.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import YandexMapKit

open class AbstractMapDataAdapter: NSObject, YMKMapObjectTapListener, YMKMapInputListener, YMKMapCameraListener, YMKUserLocationObjectListener {
    
    public weak var delegate: MapDataDelegate?
    
    public var mapView: YMKMapView? {
        didSet {
            initiateUserLocationSettings()
        }
    }
    
    var userLocationLayer: YMKUserLocationLayer?
    
    open func initiateUserLocationSettings() {
        if let mapView = mapView {
            let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
            self.userLocationLayer = userLocationLayer
            
            userLocationLayer.setVisibleWithOn(true)
            userLocationLayer.isHeadingEnabled = true
            userLocationLayer.setObjectListenerWith(self)
        }
    }
    
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
    
    public var didFirstGestureScroll = false
    
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
    
    
    public var customLocation: Marker? {
        didSet {
            if let placemark = oldValue?.Placemark, placemark.isValid {
                map?.mapObjects.remove(with: placemark)
            }
        }
    }
    
    var lastZoom: Float = 0
    
    open func initiatePin(object: AnyHashable) -> Pin? {
        return Pin(object)
    }
    
    open func initiateCluster(coordinates: YMKPoint) -> Cluster {
        return Cluster(coordinate: coordinates)
    }
    
    open func needScrollToTapPin() -> Bool {
        return false
    }
    
    open func needScrollWithSetMarkers() -> Bool {
        return true
    }
    
    var lastSettingMarkersWork: DispatchWorkItem?
    
    var isNewMarkers: Bool = true
    
    open func setMarkers(objects: [AnyHashable]) {
        setMarkers(objects: objects, withScroll: needScrollWithSetMarkers())
    }
    
    open func setMarkers(objects: [AnyHashable], withScroll: Bool) {
        
        if let selectedMarker = selectedPin, !objects.contains(where: {$0 == selectedMarker.object}) {
            setSelectedPin(nil)
        }
        
        isNewMarkers = true
        
        if objects.count != 0 {
            
            if !(lastSettingMarkersWork?.isCancelled ?? true) {
                lastSettingMarkersWork?.cancel()
            }
            
            var work: DispatchWorkItem!
            work = DispatchWorkItem { [weak self] in
                let clusteringManager = self?.clusteringManager
                let customLocation = self?.customLocation
                
                var pins: [Pin] = []
                let bounds = withScroll ? BoundsMapMarkers() : nil
                
                var minDistancePin: Pin?
                var minDistance: Double?
                
                objects.forEach { (object: AnyHashable) in
                    if let pin = self?.initiatePin(object: object) {
                        pins.append(pin)
                        
                        if customLocation != nil {
                            let dist = pin.Coordinate.distance(to: customLocation!.Coordinate)
                            
                            if minDistance == nil || (dist != nil && (dist ?? 0) < (minDistance ?? 0)) {
                                minDistancePin = pin
                                minDistance = dist
                            }
                        } else {
                            bounds?.addPoint(point: pin.Coordinate)
                        }
                    }
                }
                if let pin = minDistancePin {
                    bounds?.addPoint(point: pin.Coordinate)
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
                        
                        _self.updateVisibleArea(bounds)
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
    
    var lastSettingCustomLocationWork: DispatchWorkItem?
    
    open func setCustomLocation(marker: Marker?, withScroll: Bool) {
        
        customLocation = marker
        
        if !(lastSettingCustomLocationWork?.isCancelled ?? true) {
            lastSettingCustomLocationWork?.cancel()
        }
        
        var work: DispatchWorkItem!
        work = DispatchWorkItem { [weak self] in
            let pins = self?.pins ?? []
            
            let bounds = withScroll ? BoundsMapMarkers() : nil
            
            if withScroll {
                var minDistancePin: Pin?
                var minDistance: Double?
                
                for pin in pins {
                    if marker != nil {
                        let dist = pin.Coordinate.distance(to: marker!.Coordinate)
                        
                        if minDistance == nil || (dist != nil && (dist ?? 0) < (minDistance ?? 0)) {
                            minDistancePin = pin
                            minDistance = dist
                        }
                    } else {
                        bounds?.addPoint(point: pin.Coordinate)
                    }
                }
                
                if let pin = minDistancePin {
                    bounds?.addPoint(point: pin.Coordinate)
                }
            }
            
            if !work.isCancelled {
                DispatchQueue.main.sync { [weak self] in
                    self?.updateVisibleArea(bounds)
                }
            }
        }
        lastSettingCustomLocationWork = work
        delegate?.willBeginUpdateMarkers()
        DispatchQueue.global(qos: .userInteractive).async(execute: work)
    }
    
    func updateVisibleArea(_ bounds: BoundsMapMarkers?) {
        if let map = mapView?.mapWindow.map, let bounds = bounds {
            
            if let coordCustomLocation = customLocation?.Coordinate, (customLocation?.isVisible ?? false) || userLocation == nil {
                bounds.addPoint(point: coordCustomLocation)
            } else {
                if let userLocation = userLocation {
                    bounds.addPoint(point: userLocation)
                }
            }
            
            let cameraPosition = map.cameraPosition(with: bounds.getBoundingBox())
            
            var zoom = cameraPosition.zoom - ((customLocation == nil) ? 0.2 : 1)
            if (zoom > zoomLevel.maxZoom) {
                zoom = zoomLevel.maxZoom
            }
            move(target: cameraPosition.target, zoom: zoom, fast: true)
        } else {
            updateMarkersInThread(afterSetMarkers: true)
        }
    }
    
    open var userLocation: YMKPoint? {
        get {
            return userLocationLayer?.cameraPosition()?.target
        }
    }
    
    func cleanMarkers() {
        didFirstGestureScroll = false
        
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
                        _self.customLocation?.Placemark = nil
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
                    
                    _self.updateCustomLocation()
                    
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
    
    func updateCustomLocation() {
        if let marker = customLocation {
            var coords = marker.Coordinate
            if coords.isZero, let ul = userLocation {
                coords = ul
            }
            if !(marker.Placemark?.isValid ?? false), let placemark = map?.mapObjects.addEmptyPlacemark(with: coords) {
                marker.Placemark = placemark
            }
            marker.Placemark?.isVisible = userLocation != nil ? marker.isVisible : !coords.isZero
        }
    }
    
    public init(mapView: YMKMapView) {
        super.init()
        
        self.mapView = mapView
        initClusteringManager()
        initiateMapSettings()
        initiateUserLocationSettings()
    }
    
    public init(bounds: CGRect) {
        super.init()
        
        self.mapView = YMKMapView(frame: bounds)
        initClusteringManager()
        initiateMapSettings()
        initiateUserLocationSettings()
    }
    
    open func initiateMapSettings() {
        map?.addInputListener(with: self)
        map?.addCameraListener(with: self)
        map?.logo.setAlignmentWith(YMKLogoAlignment(horizontalAlignment: .left, verticalAlignment: .bottom))
    }
    
    public func moveToCurrentLocation() {
        if let userLocation = userLocation {
            move(target: userLocation, zoom: zoomLevel.defaultUserLocationCameraZoom, fast: false)
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
    
    public func setCityLocation(latitude: Double, longitude: Double) {
        if map != nil {
            move(target: YMKPoint(latitude: latitude, longitude: longitude), zoom: 8, fast: true)
        }
    }
    
    public func move(latitude: Double, longitude: Double, zoom: Float, fast: Bool = false) {
        if map != nil {
            move(target: YMKPoint(latitude: latitude, longitude: longitude), zoom: zoom, fast: fast)
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
                    duration: fast ? 0 : 0.2))
        }
    }
    
    private func moveToPin(target: YMKPoint, fast: Bool = false) {
        if let map = map {
            move(
                target: target,
                zoom: map.cameraPosition.zoom >= zoomLevel.defaultCameraZoom
                    ? map.cameraPosition.zoom : zoomLevel.defaultCameraZoom,
                fast: fast)
        }
    }
    
    public func selectOnMap(object: AnyHashable, fast: Bool = false) {
        for pin in pins {
            if pin.object == object {
                unselectPin(newSelectedPin: pin, needNotificate: false)
                
                pin.IsSelected = true
                selectedPin = pin
                
                moveToPin(target: pin.Coordinate, fast: fast)
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
                
                if needScrollToTapPin() {
                    moveToPin(target: newSelectedPin.Coordinate)
                }
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
                duration: 0))
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
        if cameraUpdateSource == YMKCameraUpdateSource.gestures {
            didFirstGestureScroll = true
        }
        
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
        
        if type(of: event) == YMKUserLocationIconChanged.self {
            updateCustomLocation()
        }
    }
}
