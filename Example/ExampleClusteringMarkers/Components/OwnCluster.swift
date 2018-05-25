//
//  OwnCluster.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import ClusteringMarkers

public class StoreCluster : Cluster {
    
    override public func setIcon() {
        let config = ClusterViewConfiguration()
        
        config.displayedLabel = nil
        config.contentView = nil
        
        Placemark?.setIconWith(config.getClusterImage(number: number, displayedText: displayedTitle))
    }
}
