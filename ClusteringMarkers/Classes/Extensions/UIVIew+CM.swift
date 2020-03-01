//
//  UIVIew+CM.swift
//  ClusteringMarkers
//
//  Created by Александр Смородов on 27.02.2020.
//

import UIKit

extension UIView {
    
    public func snapshot() -> UIImage? {
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}
