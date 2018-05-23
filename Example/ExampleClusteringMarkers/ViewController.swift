//
//  ViewController.swift
//  ExampleClusteringMarkers
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YandexMapKit
import ClusteringMarkers


class ViewController: UIViewController {

    @IBOutlet var mapView: YMKMapView!
    
    var markers: [Marker] = []
    let clusteringManager = ClusteringManager<StoreCluster>()
    var selectedMarker: OwnMarker?
    
    var lastZoom: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.mapWindow.map?.addInputListener(with: self)
        mapView.mapWindow.map?.addCameraListener(with: self)
        
        for lat in 1...50 {
            for lng in 1...50 {
                markers.append(OwnMarker(point: YMKPoint(
                    latitude: 56.0 + Double(lat) / 200,
                    longitude: 59.0 + Double(lng) / 100)))
            }
        }
        clusteringManager.add(markers: markers)
        
        updateMarkers()
    }

    func updateMarkers() {
        
        let clusteredPlacemarks = clusteringManager.clusteredMarkers(
            withinVisibleRegion: self.mapView.mapWindow.focusRegion,
            zoomScale: self.mapView.mapWindow.map?.cameraPosition.zoom ?? ZoomLevel.DEFAULT_ZOOM)
        
        if let map = self.mapView.mapWindow.map {
            
            if ZoomLevel.isDifferentZoom(lastZoom: lastZoom, currentZoom: map.cameraPosition.zoom) {
                mapView.mapWindow.map?.mapObjects?.clear()
                markers.forEach { (marker) in
                    marker.Placemark = nil
                    if type(of: marker) is Cluster.Type, let index = markers.index(of: marker) {
                        markers.remove(at: index)
                    }
                }
            }
            
            for marker in markers {
                if let placemark = marker.Placemark, !self.mapView.mapWindow.focusRegion.isInVisibleRegion(point: placemark.geometry, zoom: map.cameraPosition.zoom) {
                    mapView.mapWindow.map?.mapObjects?.remove(with: placemark)
                    marker.Placemark = nil
                    if type(of: marker) is Cluster.Type, let index = markers.index(of: marker) {
                        markers.remove(at: index)
                    }
                }
            }
        }
        
        for marker in clusteredPlacemarks {
            
            if marker.Placemark == nil, let _m = marker as? OwnMarker, let placemark = mapView.mapWindow.map?.mapObjects?.addEmptyPlacemark(with: _m.Coordinate) {
                if let selectedMarker = selectedMarker, _m == selectedMarker{
                    _m.IsSelected = true
                }
                _m.Placemark = placemark
                placemark.addTapListener(with: self)
            }
            
            if !markers.contains(marker), let cl = marker as? Cluster, let placemark = mapView.mapWindow.map?.mapObjects?.addEmptyPlacemark(with: cl.Coordinate) {
                cl.Placemark = placemark
                placemark.addTapListener(with: self)
                markers.append(marker)
            }
        }
    }
    public func selectOnMap(placemark: YMKPlacemarkMapObject?) {
        
        if let _pl = placemark {
            if let newSelectedMarker = markers.first(where:
                {
                    $0.Placemark?.geometry.latitude == _pl.geometry.latitude &&
                        $0.Placemark?.geometry.longitude == _pl.geometry.longitude
            }) {
                
                if let _m = newSelectedMarker as? OwnMarker {
                    select(marker: _m)
                }
                
                if let cl = newSelectedMarker as? Cluster, let map = mapView.mapWindow.map {
                    let cameraPosition = map.cameraPosition(with: cl.bounds)
                    let boundsZoom = cameraPosition.zoom - 0.2
                    
                    if ZoomLevel.canZoomInCluster(currentZoom: map.cameraPosition.zoom, boundsZoom: boundsZoom) {
                        self.move(target: cameraPosition.target, zoom: ZoomLevel.zoomInCluster(boundsZoom: boundsZoom))
                    } else {
                        self.move(target: cl.centerMarkers, zoom: ZoomLevel.zoomMoreThan(currentZoom: map.cameraPosition.zoom))
                    }
                }
            }
        } else {
            unselectAllExcept(newSelectedMarker: nil)
        }
    }
    private func unselectAllExcept(newSelectedMarker: OwnMarker?) {
        markers.filter({$0.IsSelected}).forEach { (marker) in
            if let _m = marker as? OwnMarker, newSelectedMarker == nil || newSelectedMarker != _m {
                marker.IsSelected = false
            }
        }
    }
    private func select(marker: OwnMarker) {
        marker.IsSelected = true
        selectedMarker = marker
        
        if let map = mapView.mapWindow.map {
            move(
                target: marker.Coordinate,
                zoom: map.cameraPosition.zoom >= ZoomLevel.DEFAULT_CAMERA_ZOOM
                    ? map.cameraPosition.zoom : ZoomLevel.DEFAULT_CAMERA_ZOOM)
        }
    }
    
    private func move(target: YMKPoint, zoom: Float) {
        if let map = mapView.mapWindow.map {
            mapView.mapWindow.map?.move(
                with: YMKCameraPosition(
                    target: target,
                    zoom: zoom,
                    azimuth: map.cameraPosition.azimuth,
                    tilt: map.cameraPosition.tilt),
                animationType: YMKAnimation(
                    type: YMKAnimationType.smooth,
                    duration: 0.2),
                cameraCallback: nil)
        }
    }
}


extension ViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject?, point: YMKPoint) -> Bool {
        
        if let _pl = mapObject as? YMKPlacemarkMapObject {
            selectOnMap(placemark: _pl)
        }
        return true
    }
}

extension ViewController: YMKMapInputListener {
    
    func onMapTap(with map: YMKMap?, point: YMKPoint) {
        selectOnMap(placemark: nil)
    }
    
    func onMapLongTap(with map: YMKMap?, point: YMKPoint) {
    }
}

extension ViewController: YMKMapCameraListener {
    
    func onCameraPositionChanged(with map: YMKMap?, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
        
        updateMarkers()
        lastZoom = cameraPosition.zoom
    }
}
