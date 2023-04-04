//
//  ScrollAnimation.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 04.04.2023.
//

import YandexMapKit

open class ScrollAnimation {
    
    public typealias AnimationType = YMKAnimationType
    
    public var type: AnimationType
    public var duration: TimeInterval
    
    public init(type: AnimationType, duration: TimeInterval) {
        self.type = type
        self.duration = duration
    }
    
    public static var smooth: ScrollAnimation {
        .init(type: .smooth, duration: 0.2)
    }
    
    public static var immediate: ScrollAnimation {
        .init(type: .linear, duration: 0)
    }
}
