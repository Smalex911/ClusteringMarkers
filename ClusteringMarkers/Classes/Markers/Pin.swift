//
//  Pin.swift
//  Created by Aleksandr Smorodov on 31.5.19.
//

import UIKit
import YandexMapKit

open class Pin: Marker {
    
    public var object: AnyHashable?
    
    public required init(_ object: AnyHashable) {
        self.object = object
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        
        object.hash(into: &hasher)
    }
}
