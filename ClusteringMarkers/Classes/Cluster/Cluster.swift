//
//  Cluster.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import YandexMapKit
import AlamofireImage

public typealias Cluster = YMKCluster

extension Cluster {
    
    public func setCachedImage(withIdentifier identifier: String, imageCache: AutoPurgingImageCache?, imageIfNotCached: (() -> UIImage?)) {
        
        let identifier = "cluster-\(identifier)"
        
        if let image = imageCache?.image(withIdentifier: identifier) {
            appearance.setIconWith(image)
            
        } else if let image = imageIfNotCached() {
            imageCache?.add(image, withIdentifier: identifier)
            appearance.setIconWith(image)
            
        } else {
            imageCache?.removeImage(withIdentifier: identifier)
        }
    }
}
