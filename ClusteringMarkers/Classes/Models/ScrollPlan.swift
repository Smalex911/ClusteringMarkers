//
//  ScrollPlan.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 04.04.2023.
//

import Foundation

open class ScrollPlan {
    
    public var visibleBounds: BoundsMapMarkers
    public var animation: ScrollAnimation
    public var canChangeZoom: Bool
    
    public init(visibleBounds: BoundsMapMarkers, animation: ScrollAnimation, canChangeZoom: Bool = true) {
        self.visibleBounds = visibleBounds
        self.animation = animation
        self.canChangeZoom = canChangeZoom
    }
}
