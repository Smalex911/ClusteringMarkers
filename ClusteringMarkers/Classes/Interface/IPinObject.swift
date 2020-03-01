//
//  IPinObject.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 28.02.2020.
//

import Foundation

public protocol IPinObject: class {
    
    var pinLatitude: Double? { get set }
    var pinLongitude: Double? { get set }
    
    func isEqual(_ object: Any?) -> Bool
    
    var hasLocation: Bool { get }
}

extension IPinObject {
    
    public var hasLocation: Bool {
        return (pinLatitude ?? 0) != 0 && (pinLongitude ?? 0) != 0
    }
}
