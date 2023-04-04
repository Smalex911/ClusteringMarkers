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
    
    public init(visibleBounds: BoundsMapMarkers, animation: ScrollAnimation) {
        self.visibleBounds = visibleBounds
        self.animation = animation
    }
}
