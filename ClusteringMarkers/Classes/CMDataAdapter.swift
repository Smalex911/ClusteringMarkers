//
//  CMDataAdapter.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import YandexMapKit
import AlamofireImage

open class CMDataAdapter: NSObject, YMKClusterListener, YMKClusterTapListener, YMKMapObjectTapListener, YMKMapInputListener, YMKMapCameraListener, YMKUserLocationObjectListener {
    
    public var didFirstGestureScroll = false
    
    
    //MARK: - Initialization
    
    public weak var delegate: CMDelegate?
    var imageCache: AutoPurgingImageCache?
    
    public init(
        mapView: YMKMapView = YMKMapView(),
        imageCache: AutoPurgingImageCache? = AutoPurgingImageCache(),
        delegate: CMDelegate
    ) {
        self.imageCache = imageCache
        self.delegate = delegate
        self.mapView = mapView
        
        super.init()
        
        initiateMapSettings()
        initiateClustersCollection()
        initiateUserLocationSettings()
    }
    
    public convenience init(
        bounds: CGRect,
        imageCache: AutoPurgingImageCache? = AutoPurgingImageCache(),
        delegate: CMDelegate
    ) {
        self.init(
            mapView: YMKMapView(frame: bounds),
            imageCache: imageCache,
            delegate: delegate
        )
    }
    
    
    //MARK: - Map
    
    public var mapView: YMKMapView {
        didSet {
            initiateMapSettings()
            initiateClustersCollection()
            initiateUserLocationSettings()
        }
    }
    
    var map: YMKMap? {
        mapView.mapWindow.map
    }
    
    open func initiateMapSettings() {
        map?.addInputListener(with: self)
        map?.addCameraListener(with: self)
        map?.logo.setAlignmentWith(YMKLogoAlignment(horizontalAlignment: .left, verticalAlignment: .bottom))
    }
    
    
    //MARK: - Clusters
    
    var clustersCollection: YMKClusterizedPlacemarkCollection? {
        didSet {
            guard let oldValue = oldValue else { return }
            
            oldValue.clear()
            oldValue.parent.remove(with: oldValue)
        }
    }
    
    open func initiateClustersCollection() {
        
        clustersCollection = map?.mapObjects.addClusterizedPlacemarkCollection(with: self)
    }
    
    
    //MARK: - User Location
    
    open var userLocation: YMKPoint? {
        return userLocationLayer?.cameraPosition()?.target
    }
    
    var userLocationLayer: YMKUserLocationLayer?
    
    open func initiateUserLocationSettings() {
        guard let mapWindow = mapView.mapWindow else { return }
        
        userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapWindow)
        
        userLocationLayer?.setVisibleWithOn(true)
        userLocationLayer?.isHeadingEnabled = true
        userLocationLayer?.setObjectListenerWith(self)
    }
    
    
    //MARK: - Parameters
    
    /**
     Minimal distance in units between objects that remain separate.
     
     The size of the unit is equal to the size of a pixel when the camera position's tilt is equal to 0 and the scale factor is equal to 1.
     */
    open var clusterRadius: Double {
        return 60
    }
    
    /**
     Minimal zoom level that displays clusters.
     
     All placemarks will be rendered separately at more detailed zoom levels. The value will be clipped between 0 and 19 (most detailed zoom).
     */
    open var minClusterZoom: UInt {
        return 14
    }
    
    /**
     Zoom level for move to pin
     
     The value between 0 and 19 (most detailed zoom) is recommended.
     */
    open var pinTargetCameraZoom : Float {
        return 16
    }
    
    /**
     Zoom level for move to user location.
     
     The value between 0 and 19 (most detailed zoom) is recommended.
     */
    open var userLocationCameraZoom : Float {
        return 13
    }
    
    
    //MARK: - Markers
    
    var pins: [Pin]?
    
    var lastSettingMarkersWork: DispatchWorkItem?
    
    open func initiatePin(object: IPinObject) -> Pin? {
        return Pin(object)
    }
    
    open func setMarkers(with objects: [IPinObject], withMoveToBounds moveToBounds: Bool = true) {
        if let selectedMarker = selectedPin, !objects.contains(where: { $0.isEqual(selectedMarker.object) }) {
            setSelectedPin(nil)
        }
        
        if objects.count != 0 {
            
            if !(lastSettingMarkersWork?.isCancelled ?? true) {
                lastSettingMarkersWork?.cancel()
            }
            
            let focusRegion = self.mapView.mapWindow.focusRegion
            let userLocation = self.userLocation
            let objects: [IPinObject]? = objects
            
            var work: DispatchWorkItem!
            work = DispatchWorkItem { [weak self] in
                guard let `self` = self else { return }
                let customLocation = self.markerCustomLocation
                
                var pins: [Pin] = []
                var scrollPlan: ScrollPlan?
                
                let initiatePinsBlock = { (setupPinHandler: (_ pin: Pin) -> Void) in
                    objects?.forEach { object in
                        if let pin = self.initiatePin(object: object) {
                            pin.imageCache = self.imageCache
                            
                            pins.append(pin)
                            setupPinHandler(pin)
                        }
                    } ?? ()
                }
                
                if moveToBounds {
                    scrollPlan = self.getScrollPlan(
                        focusRegion: focusRegion,
                        userLocation: userLocation,
                        customMarker: customLocation,
                        cycleHandler: initiatePinsBlock
                    )
                } else {
                    initiatePinsBlock { _ in }
                }
                
                if !work.isCancelled {
                    DispatchQueue.main.sync { [weak self] in
                        guard let `self` = self else { return }
                        let isNew = self.pins == nil
                        
                        self.pins = pins
                        self.setScrollPlan(scrollPlan, forceMove: isNew)
                        self.updateMarkers()
                    }
                }
            }
            lastSettingMarkersWork = work
            delegate?.willBeginUpdatingMarkers()
            DispatchQueue.global(qos: .userInteractive).async(execute: work)
        } else {
            cleanMarkers()
        }
    }
    
    open func updatePinIcons() {
        pins?.forEach { pin in
            pin.setIcon()
        }
    }
    
    open func didEndUpdatingMarkers() {
        delegate?.didEndUpdatingMarkers(true)
    }
    
    func updateMarkers() {
        if let collection = map?.mapObjects.addClusterizedPlacemarkCollection(with: self) {
            
            pins?.forEach { pin in
                let placemark = collection.addEmptyPlacemark(with: pin.Coordinate)
                
                if selectedPin == pin && !pin.isSelected {
                    pin.isSelected = true
                    selectedPin = pin
                }
                pin.Placemark = placemark
                placemark.userData = pin
                placemark.addTapListener(with: self)
            }
            
            collection.clusterPlacemarks(withClusterRadius: clusterRadius, minZoom: minClusterZoom)
            
            clustersCollection = collection
        }
        
        updateCustomLocation()
        didEndUpdatingMarkers()
    }
    
    func cleanMarkers() {
        didFirstGestureScroll = false
        pins = nil
        updateMarkers()
    }
    
    
    //MARK: - Scroll Plan
    
    open func getScrollPlan(focusRegion: YMKVisibleRegion?, userLocation: YMKPoint?, customMarker: Marker?, cycleHandler: (((_ pin: Pin) -> Void) -> Void)) -> ScrollPlan? {
        
        var bounds: BoundsMapMarkers? = .init()
        createVisibleArea(&bounds, focusRegion: focusRegion, userLocation: userLocation, customMarker: customMarker, cycleHandler: cycleHandler)
        
        guard let bounds = bounds else { return nil }
        return .init(visibleBounds: bounds, animation: .immediate)
    }
    
    @available(*, deprecated, renamed: "getScrollPlan(focusRegion:userLocation:customMarker:cycleHandler:)")
    open func createVisibleArea(_ bounds: inout BoundsMapMarkers?, focusRegion: YMKVisibleRegion?, userLocation: YMKPoint?, customMarker: Marker?, cycleHandler: (((_ pin: Pin) -> Void) -> Void)) {
        var minDistancePin: Pin?
        var minDistance: Double?
        
        cycleHandler { pin in
            if bounds != nil {
                if customMarker != nil {
                    let dist = pin.Coordinate.distance(to: customMarker!.Coordinate)
                    
                    if minDistance == nil || (dist != nil && (dist ?? 0) < (minDistance ?? 0)) {
                        minDistancePin = pin
                        minDistance = dist
                    }
                } else {
                    bounds?.addPoint(point: pin.Coordinate)
                }
            }
        }
        
        if bounds != nil {
            if let pin = minDistancePin {
                bounds?.addPoint(point: pin.Coordinate)
            }
            
            if let coordCustomLocation = customMarker?.Coordinate, (customMarker?.isVisible ?? false) || userLocation == nil {
                bounds?.addPoint(point: coordCustomLocation)
            } else {
                if let userLocation = userLocation {
                    bounds?.addPoint(point: userLocation)
                }
            }
        }
    }
    
    open func needToMoveInUpdateVisibleArea(forceMove: Bool) -> Bool {
        return forceMove || !didFirstGestureScroll
    }
    
    func setScrollPlan(_ scrollPlan: ScrollPlan?, forceMove: Bool) {
        guard let map = map,
              let scrollPlan = scrollPlan,
              needToMoveInUpdateVisibleArea(forceMove: forceMove)
        else { return }
        
        let cameraPosition = map.cameraPosition(with: scrollPlan.visibleBounds.getBoundingBox())
        move(with: cameraPosition.target, zoom: zoomOutForBounds(cameraPosition.zoom), animation: scrollPlan.animation, isGestureScroll: false)
    }
    
    open func zoomOutForBounds(_ zoom: Float) -> Float {
        
        var zoom = zoom
        
        switch zoom {
        case 16.5...Float.infinity:
            zoom -= 1
            break
        case 9.5...16.5:
            zoom -= ((1 - 0.2) * zoom + (16.5 * 0.2 - 9.5 * 1)) / (16.5 - 9.5)
            break
        default:
            zoom -= 0.2
            break
        }
        
        return zoom
    }
    
    
    //MARK: - Custom Location
    
    public var markerCustomLocation: Marker? {
        didSet {
            if let placemark = oldValue?.Placemark, placemark.isValid {
                map?.mapObjects.remove(with: placemark)
                oldValue?.Placemark = nil
            }
            updateCustomLocation()
        }
    }
    
    var lastSettingCustomLocationWork: DispatchWorkItem?
    
    open func setCustomLocation(marker: Marker?, withScroll: Bool) {
        markerCustomLocation = marker
        
        if !(lastSettingCustomLocationWork?.isCancelled ?? true) {
            lastSettingCustomLocationWork?.cancel()
        }
        
        if withScroll {
            updateVisibleArea(forceMove: true)
        }
    }
    
    func updateVisibleArea(forceMove: Bool) {
        let focusRegion = self.mapView.mapWindow.focusRegion
        let userLocation = self.userLocation
        let customLocation = self.markerCustomLocation
        
        var work: DispatchWorkItem!
        work = DispatchWorkItem { [weak self] in
            guard let `self` = self else { return }
            
            let pins = self.pins
            let scrollPlan = self.getScrollPlan(
                focusRegion: focusRegion,
                userLocation: userLocation,
                customMarker: customLocation,
                cycleHandler: { setupPinHandler in
                    pins?.forEach { setupPinHandler($0) }
                }
            )
            
            if !work.isCancelled {
                DispatchQueue.main.sync { [weak self] in
                    self?.setScrollPlan(scrollPlan, forceMove: forceMove)
                }
            }
        }
        lastSettingCustomLocationWork = work
        DispatchQueue.global(qos: .userInteractive).async(execute: work)
    }
    
    func updateCustomLocation() {
        
        guard let markerCL = markerCustomLocation else { return }
        
        var coords = markerCL.Coordinate
        if coords.isZero, let ul = userLocation {
            coords = ul
        }
        if !(markerCL.Placemark?.isValid ?? false), let placemark = map?.mapObjects.addEmptyPlacemark(with: coords) {
            markerCL.Placemark = placemark
        }
        markerCL.Placemark?.isVisible = userLocation != nil ? markerCL.isVisible : !coords.isZero
    }
    
    
    //MARK: - Move Camera Position
    
    open func moveToCurrentLocation(deniedCompletion: (() -> Void)? = nil, isGestureScroll: Bool = true) {
        guard let userLocation = userLocation else {
            deniedCompletion?()
            return
        }
        
        if let cameraZoom = map?.cameraPosition.zoom {
            let targetZoom = userLocationCameraZoom
            let zoom = cameraZoom < targetZoom ? targetZoom : cameraZoom
            move(with: userLocation, zoom: zoom, animation: .smooth, isGestureScroll: true)
        } else {
            move(with: userLocation, zoom: userLocationCameraZoom, animation: .smooth, isGestureScroll: true)
        }
    }
    
    public func move(zoomDiff: Float, animation: ScrollAnimation = .smooth, isGestureScroll: Bool = true) {
        guard let map = map else { return }
        move(with: map.cameraPosition.target, zoom: map.cameraPosition.zoom + zoomDiff, animation: animation, isGestureScroll: true)
    }
    
    public func setCityLocation(latitude: Double, longitude: Double) {
        guard let _ = map else { return }
        move(with: YMKPoint(latitude: latitude, longitude: longitude), zoom: 8, animation: .immediate)
    }
    
    public func move(latitude: Double, longitude: Double, zoom: Float, animation: ScrollAnimation = .smooth, isGestureScroll: Bool = true) {
        guard let _ = map else { return }
        move(with: YMKPoint(latitude: latitude, longitude: longitude), zoom: zoom, animation: animation, isGestureScroll: isGestureScroll)
    }
    
    /**
     - parameter targetZoom: Zoom level for move to pin. Return `nil` to disable zoom. `nil` by default.
     */
    open func move(with pin: Pin, targetZoom: Float? = nil, animation: ScrollAnimation = .smooth, isGestureScroll: Bool = true) {
        guard let cameraZoom = map?.cameraPosition.zoom else { return }
        let zoom = targetZoom != nil && cameraZoom < targetZoom! ? targetZoom! : cameraZoom
        move(with: pin.Coordinate, zoom: zoom, animation: animation, isGestureScroll: isGestureScroll)
    }
    
    open func move(with cluster: Cluster, animation: ScrollAnimation = .smooth, isGestureScroll: Bool = true) {
        guard let map = map else { return }
        
        let bounds = cluster.placemarks.reduce(BoundsMapMarkers(azimuth: Double(map.cameraPosition.azimuth))) { (res, placemark) -> BoundsMapMarkers in
            res.addPoint(point: placemark.geometry)
            return res
        }
        
        let cameraPosition = map.cameraPosition(with: bounds.getBoundingBox())
        var zoom = cameraPosition.zoom
        let minClusterZoom = Float(self.minClusterZoom)
        
        if zoom > minClusterZoom {
            zoom = zoomOutForBounds(cameraPosition.zoom)
            
            if zoom < minClusterZoom {
                zoom = minClusterZoom
            }
        }
        
        if zoom <= map.cameraPosition.zoom {
            zoom = map.cameraPosition.zoom + 0.5
        }
        
        move(with: cameraPosition.target, zoom: zoom, animation: animation, isGestureScroll: isGestureScroll)
    }
    
    private func move(with target: YMKPoint, zoom: Float, animation: ScrollAnimation = .smooth, isGestureScroll: Bool = true) {
        guard let map = map else { return }
        
        map.move(
            with: YMKCameraPosition(
                target: target,
                zoom: zoom.isNaN ? 0 : zoom,
                azimuth: map.cameraPosition.azimuth,
                tilt: map.cameraPosition.tilt),
            animationType: YMKAnimation(
                type: animation.type,
                duration: Float(animation.duration)))
        
        if isGestureScroll {
            didFirstGestureScroll = true
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
    
    
    //MARK: - Select Map Object
    
    var selectedPin: Pin? {
        didSet {
            if oldValue != selectedPin && (oldValue?.isValid ?? false) {
                oldValue?.isSelected = false
            }
        }
    }
    
    func setSelectedPin(_ pin: Pin?, needNotificate: Bool = true) {
        
        if selectedPin != pin {
            selectedPin = pin
            
            if needNotificate {
                delegate?.mapDataAdapter(self, didSelectPin: selectedPin)
            }
        } else if !(selectedPin?.isValid ?? true) {
            selectedPin = pin
        }
    }
    
    /**
     - parameter targetZoom: Zoom level for move to pin. Return `nil` to disable transition. `nil` by default.
     */
    public func select(object: IPinObject?, targetZoom: Float? = nil, animation: ScrollAnimation = .smooth) {
        guard let object = object else {
            unselectPin()
            return
        }
        
        guard let pin = pins?.first(where: { object.isEqual($0.object) }) else { return }
        unselectPin(newSelectedPin: pin, needNotificate: false)
        
        pin.isSelected = true
        selectedPin = pin
        
        if let targetZoom = targetZoom {
            move(with: pin, targetZoom: targetZoom, animation: animation, isGestureScroll: true)
        }
    }
    
    public func select(placemark: YMKPlacemarkMapObject?) {
        guard let placemark = placemark else {
            unselectPin()
            return
        }
        
        guard let newSelectedPin = pins?.first(where: { $0.isEqual(placemark: placemark) }) else { return }
        
        newSelectedPin.isSelected = true
        setSelectedPin(newSelectedPin)
        
        if delegate?.mapDataAdapter(self, didTapPin: newSelectedPin) ?? false {
            didFirstGestureScroll = true
        }
    }
    
    private func unselectPin(newSelectedPin: Pin? = nil, needNotificate: Bool = true) {
        guard let selectedPin = pins?.first(where: { $0.isSelected }) else { return }
        
        if newSelectedPin == nil || newSelectedPin != selectedPin {
            setSelectedPin(nil, needNotificate: needNotificate)
            selectedPin.isSelected = false
        }
    }
    
    //MARK: - Update Map Object
    
    public func update(object: IPinObject?) {
        guard let object = object else { return }
        guard let pin = pins?.first(where: { object.isEqual($0.object) }) else { return }
        pin.setIcon()
    }
    
    public func update(placemark: YMKPlacemarkMapObject?) {
        guard let placemark = placemark else { return }
        guard let pin = pins?.first(where: { $0.isEqual(placemark: placemark) }) else { return }
        pin.setIcon()
    }
    
    //MARK: - YMKClusterListener
    
    open func onClusterAdded(with cluster: YMKCluster) {
        
        styleCluster(with: cluster, imageCache: imageCache)
        cluster.addClusterTapListener(with: self)
    }
    
    open func styleCluster(with cluster: Cluster, imageCache: AutoPurgingImageCache?) {
        
        cluster.setCachedImage(
            withIdentifier: "\(cluster.size)",
            imageCache: imageCache,
            style: IconStyle(zIndex: NSNumber(value: cluster.size))
            )
        { () -> UIImage? in
            return ClusterView(number: cluster.size, displayedText: "\(cluster.size)").snapshot()
        }
    }
    
    
    //MARK: - YMKClusterTapListener
    
    open func onClusterTap(with cluster: YMKCluster) -> Bool {
        delegate?.onMapTap(lat: cluster.appearance.geometry.latitude, lng: cluster.appearance.geometry.longitude)
        
        if delegate?.mapDataAdapter(self, didTapPin: cluster) ?? false {
            didFirstGestureScroll = true
        }
        
        return true
    }
    
    
    //MARK: - YMKMapObjectTapListener
    
    open func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        delegate?.onMapTap(lat: point.latitude, lng: point.longitude)
        
        guard let placemark = mapObject as? YMKPlacemarkMapObject else { return true }
        select(placemark: placemark)
        return true
    }
    
    
    //MARK: - YMKMapInputListener
    
    open func onMapTap(with map: YMKMap, point: YMKPoint) {
        delegate?.onMapTap(lat: point.latitude, lng: point.longitude)
        unselectPin()
    }
    
    open func onMapLongTap(with map: YMKMap, point: YMKPoint) {
        delegate?.onMapLongTap(lat: point.latitude, lng: point.longitude)
    }
    
    
    //MARK: - YMKMapCameraListener
    
    private var scrollActive: Bool = false
    
    open func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
        
        let isGesture = cameraUpdateSource == YMKCameraUpdateSource.gestures
        
        if isGesture {
            didFirstGestureScroll = true
        }
        
        if !scrollActive {
            scrollActive = true
            
            delegate?.willBeginScrollingMap(isGesture)
        }
        
        if finished {
            scrollActive = false
            
            delegate?.didEndScrollingMap(isGesture)
        }
    }
    
    
    //MARK: - YMKUserLocationObjectListener
    
    open func onObjectAdded(with view: YMKUserLocationView) {
        
    }
    
    open func onObjectRemoved(with view: YMKUserLocationView) {
        
    }
    
    open func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {
        
        if type(of: event) == YMKUserLocationIconChanged.self {
            updateCustomLocation()
            
            if needToMoveInUpdateVisibleArea(forceMove: false) {
                updateVisibleArea(forceMove: false)
            }
        }
    }
}
