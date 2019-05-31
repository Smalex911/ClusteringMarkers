//
//  StoreCluster.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 23.05.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import YandexMapKit
import ClusteringMarkers

public class StoreCluster : Cluster {
    
    override public func setIcon() {
        let config = ClusterViewConfiguration()
        let rect = config.getRect(number: number)
        
        let labelTitle = UILabel(frame: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height + 1))
        labelTitle.font = UIFont.systemFont(ofSize: config.getFontSize(number: number))
        labelTitle.textColor = .white
        labelTitle.textAlignment = .center
        labelTitle.text = displayedTitle
        config.displayedLabel = labelTitle
        
        let view = UIView(frame: config.getRect(number: number))
        view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        view.layer.cornerRadius = view.frame.height / 2
        config.contentView = view
        
        Placemark?.setIconWith(config.getClusterImage(number: number, displayedText: displayedTitle), style: YMKIconStyle(
            anchor: nil,
            rotationType: nil,
            zIndex: NSNumber(value: number),
            flat: nil,
            visible: nil,
            scale: nil,
            tappableArea: nil))
    }
}
