# ClusteringMarkers

[![Version](https://img.shields.io/cocoapods/v/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)
[![License](https://img.shields.io/cocoapods/l/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)
[![Platform](https://img.shields.io/cocoapods/p/ClusteringMarkers.svg?style=flat)](https://cocoapods.org/pods/ClusteringMarkers)

![Screen Shot](https://user-images.githubusercontent.com/26859529/58710738-70c96e80-83d6-11e9-9d1a-bd5becf66cc8.png)

## Usage

The main two classes used are Pin and Cluster. Pin contains ```AnyHashable``` object displayed on the map. You can put any class that conforms to the ```Hashable``` protocol.

### Manual use of clustering:
```swift    
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
```
### Clustering with data adapter:
```swift
    var stores: [Store] = [Store(), Store()]
        
    var mapDataAdapter = AbstractMapDataAdapter(mapView: mapView)
    mapDataAdapter.delegate = self //loading and tap markers notifications
        
    mapDataAdapter.setMarkers(objects: stores)
```
## Customization:

Pins and Clusters provides you to customize them using class inheritance.

### Pin:
```swift
    override public var Icon: UIImage? {
        return #your_image
    }
    
    override public var SelectedIcon: UIImage? {
        return #your_image
    }    
    
    override public func setIcon() {
        if let icon = IsSelected ? SelectedIcon : Icon {
            Placemark?.setIconWith(icon)
        }
    }
```
### Cluster:
```swift
    override public func setIcon() {
        let config = ClusterViewConfiguration()
        let rect = config.getRect(number: number)
        
        let labelTitle = UILabel(frame: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height + 1))
        labelTitle.font = UIFont.systemFont(ofSize: config.getFontSize(number: number))
        labelTitle.textColor = .white
        labelTitle.textAlignment = .center
        labelTitle.text = displayedTitle
        config.displayedLabel = labelTitle
        
        let view = UIView(frame: config.getRect(number: number))
        view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        view.layer.cornerRadius = view.frame.height / 2
        config.contentView = view
        
        Placemark?.setIconWith(config.getClusterImage(number: number, displayedText: displayedTitle), style: YMKIconStyle(
            anchor: nil,
            rotationType: nil,
            zIndex: NSNumber(value: number),
            flat: nil,
            visible: nil,
            scale: nil,
            tappableArea: nil))
    }
```
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
