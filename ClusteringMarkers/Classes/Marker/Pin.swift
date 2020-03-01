//
//  Pin.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import UIKit
import YandexMapKit

public protocol IPinObject: class {
    
    var latitude: Double? { get set }
    var longitude: Double? { get set }
    
    func isEqual(to object: IPinObject?) -> Bool
}

open class Pin: Marker {
    
    public var object: IPinObject?
    
    
    public required init?(_ object: IPinObject?) {
        
        guard object != nil else {
            return nil
        }
        
        self.object = object
    }
    
    override open func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        
        object?.latitude.hash(into: &hasher)
        object?.longitude.hash(into: &hasher)
    }
    
    override open var Coordinate: YMKPoint {
        return YMKPoint(
            latitude: object?.latitude ?? 0,
            longitude: object?.longitude ?? 0)
    }
    
    override open func setIcon() {
        if Placemark != nil {
            setCachedImage(withIdentifier: "\(isSelected)") { () -> UIImage? in
                
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                view.layer.cornerRadius = view.frame.width / 2
                view.backgroundColor = isSelected ? .black : .red
                
                return view.snapshot()
            }
        }
    }
}
