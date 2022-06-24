//
//  Pin.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import UIKit
import YandexMapsMobile

open class Pin: Marker {
    
    public var object: IPinObject?
    
    public override init() { }
    public init?(_ object: IPinObject?) {
        
        guard let object = object, object.hasLocation else {
            return nil
        }
        
        self.object = object
    }
    
    override open func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        
        object?.pinLatitude.hash(into: &hasher)
        object?.pinLongitude.hash(into: &hasher)
    }
    
    override open var Coordinate: YMKPoint {
        return YMKPoint(
            latitude: object?.pinLatitude ?? 0,
            longitude: object?.pinLongitude ?? 0)
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
