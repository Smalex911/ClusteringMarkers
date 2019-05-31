//
//  MapDataDelegate.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

public protocol MapDataDelegate: class {
    
    func willBeginUpdateMarkers()
    func didEndUpdateMarkers(_ afterSetMarkers: Bool)
    
    func didTapOnPin()
    func didTapOnCluster()
    
    func didSelectPin(_ pin: Pin?)
}

public extension MapDataDelegate {
    func willBeginUpdateMarkers() { }
    func didEndUpdateMarkers(_ afterSetMarkers: Bool) { }
    
    func didTapOnPin() { }
    func didTapOnCluster() { }
}
