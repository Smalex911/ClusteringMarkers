//
//  StorePin.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import YandexMapsMobile
import ClusteringMarkers

public class StorePin : Pin {
    
    override public func setIcon() {
        if Placemark != nil {
            
            let text = "lat \(Int((object?.pinLatitude ?? 0) * 100))"
            
            setCachedImage(withIdentifier: "\(text)-\(isSelected)") { () -> UIImage? in
                
//MARK: Setting icon by view as Image (best solution)
                return pinView(text, isSelected: isSelected).snapshot()
                
//MARK: Setting icon as Image (cache is not cleared automatically)
//                return pinImage(text, isSelected: IsSelected)
            }
            
//MARK: Setting icon as Image without cache (image generation cache is not cleared automatically)
//            Placemark?.setIconWith(pinImage(text, isSelected: IsSelected)!)
            
//MARK: Setting icon as View (spends a lot of time drawing, no access to cache)
//            Placemark?.setViewWithView(pinYRTView(text, isSelected: IsSelected))
        }
    }
    
    func pinImage(_ text: String, isSelected: Bool) -> UIImage? {
        return StorePinImage.image(text: text, isSelected: isSelected)
    }

    func pinView(_ text: String, isSelected: Bool) -> UIView {
        return StorePinView(text: text, isSelected: isSelected)
    }
    
    func pinYRTView(_ text: String, isSelected: Bool) -> YRTViewProvider {
        return YRTViewProvider(uiView: pinView(text, isSelected: isSelected), cacheable: false)!
    }
}
