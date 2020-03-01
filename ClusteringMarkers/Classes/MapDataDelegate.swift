//
//  MapDataDelegate.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

public protocol MapDataDelegate: class {
    
    func willBeginUpdateMarkers()
    func didEndUpdateMarkers(_ afterSetMarkers: Bool)
    
    /**
     - returns: `true` if there was a transition to a pin, `false` otherwise.
     */
    func didTap(with pin: Pin) -> Bool
    
    /**
     - returns: `true` if there was a transition to a cluster, `false` otherwise.
     */
    func didTap(with cluster: Cluster) -> Bool
    
    func didSelect(with pin: Pin?)
}

public extension MapDataDelegate {
    func willBeginUpdateMarkers() { }
    func didEndUpdateMarkers(_ afterSetMarkers: Bool) { }
    
    func didTap(with pin: Pin) -> Bool { return false }
    func didTap(with cluster: Cluster) -> Bool { return false }
}
