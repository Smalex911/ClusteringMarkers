//
//  StoreClusterView.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 27.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ClusteringMarkers

class StoreClusterView: ClusterView {
    
    override var maxDiametr: Double {
        return 45
    }
    override var minDiametr: Double {
        return 30
    }
    
    override var maxFont: Double {
        return 16
    }
    override var minFont: Double {
        return 14
    }
    
    override func styleView() {
        
        backgroundColor = UIColor.red.withAlphaComponent(0.5)
        layer.cornerRadius = frame.height / 2
    }
    
    override func styleLabel() {
        
        displayedLabel.frame = getRect()
        displayedLabel.font = font
        displayedLabel.textColor = .white
        displayedLabel.textAlignment = .center
        displayedLabel.text = displayedText
    }
    
    
}
