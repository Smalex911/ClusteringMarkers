//
//  MapDataAdapter.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 31/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ClusteringMarkers
import AlamofireImage

class MapDataAdapter: AbstractMapDataAdapter {
    
    override func initiatePin(object: IPinObject) -> Pin? {
        return StorePin(object)
    }

    override func styleCluster(with cluster: Cluster, imageCache: AutoPurgingImageCache?) {

        cluster.setCachedImage(withIdentifier: "\(cluster.size)", imageCache: imageCache) { () -> UIImage? in
            return StoreClusterView(number: cluster.size, displayedText: "\(cluster.size)").snapshot()
        }
    }
    
}
