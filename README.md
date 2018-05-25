# ClusteringMarkers

[![Version](https://img.shields.io/cocoapods/v/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)
[![License](https://img.shields.io/cocoapods/l/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)
[![Platform](https://img.shields.io/cocoapods/p/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)


## Usage

        
        var markers: [Marker] = [Marker(), Marker()]
        
        let manager = ClusteringManager<Cluster>()
        clusteringManager.replace(markers: markers)
        
        let clusteredPlacemarks = clusteringManager.clusteredMarkers(
            withinVisibleRegion: self.mapView.mapWindow.focusRegion,
            zoomScale: self.mapView.mapWindow.map?.cameraPosition.zoom ?? ZoomLevel.DEFAULT_ZOOM)
            
        for marker in clusteredPlacemarks {
        
            if let cl = marker as? Cluster, 
                let placemark = mapView.mapWindow.map?.mapObjects?.addEmptyPlacemark(with: cl.Coordinate) { }
                
            if let m = marker as? Marker, 
                let placemark = mapView.mapWindow.map?.mapObjects?.addEmptyPlacemark(with: m.Coordinate) { }
        }
        

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
To enable the Yandex Map you should get API key from [website](https://tech.yandex.ru/maps/mapkit/) and put it in AppDelegate.swift

## Installation

ClusteringMarkers is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ClusteringMarkers'
```

## Author

Aleksandr, Alex11Sm@mail.ru

## License

ClusteringMarkers is available under the MIT license. See the LICENSE file for more info.
