//
//  CMDelegate.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

public protocol CMDelegate: class {
    
    func willBeginUpdatingMarkers()
    func didEndUpdatingMarkers(_ afterSetMarkers: Bool)
    
    func willBeginScrollingMap(_ gesture: Bool)
    func didEndScrollingMap(_ gesture: Bool)
    
    func onMapTap()
    
    /**
     - returns: `true` if there was a transition to a pin, `false` otherwise.
     */
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didTapPin pin: Pin) -> Bool
    
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didSelectPin pin: Pin?)
    
    /**
     - returns: `true` if there was a transition to a cluster, `false` otherwise.
     */
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didTapPin cluster: Cluster) -> Bool
    
    
    //MARK: - Legacy
    
    @available(*, deprecated, renamed: "mapDataAdapter(_:didSelectPin:)")
    func didSelectPin(_ pin: Pin?)
}

public extension CMDelegate {
    
    func willBeginUpdatingMarkers() { }
    func didEndUpdatingMarkers(_ afterSetMarkers: Bool) { }
    
    func willBeginScrollingMap(_ gesture: Bool) { }
    func didEndScrollingMap(_ gesture: Bool) { }
    
    func onMapTap() { }
    
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didTapPin pin: Pin) -> Bool {
        mapDataAdapter.move(with: pin, targetZoom: mapDataAdapter.pinTargetCameraZoom)
        return true
    }
    
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didSelectPin pin: Pin?) { }
    
    func mapDataAdapter(_ mapDataAdapter: CMDataAdapter, didTapPin cluster: Cluster) -> Bool {
        mapDataAdapter.move(with: cluster)
        return true
    }
    
    
    //MARK: - Legacy
    @available(*, deprecated, renamed: "mapDataAdapter(_:didSelectPin:)")
    func didSelectPin(_ pin: Pin?) {
        if let _self = self as? CMDataAdapter {
            mapDataAdapter(_self, didSelectPin: pin)
        }
    }
}
