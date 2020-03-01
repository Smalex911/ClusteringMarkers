//
//  StorePinView.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 27.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class StorePinView: UIView {
    
    convenience init(text: String, isSelected: Bool) {
        
        let fontSize = CGFloat(15)
        let marginSize = CGFloat(8)
        let strokeSize = CGFloat(3)
        
        let scale = CGFloat(1)
        let font = UIFont.systemFont(ofSize: fontSize * scale)
        let sizeText = text.size(withAttributes: [NSAttributedString.Key.font: font])
        
        let internalWidth = sizeText.width + marginSize * scale * 2
        let internalHeight = sizeText.height + marginSize * scale * 2
        
        let externalWidth = internalWidth + strokeSize * scale * 2
        let externalHeight = internalHeight + strokeSize * scale * 2
        
        self.init(frame: CGRect(x: 0, y: 0, width: externalWidth, height: externalHeight))
        
        layer.cornerRadius = [externalWidth, externalHeight].min()! / 2
        backgroundColor = isSelected ? .black : .red
        
        let internalView = UIView(frame: CGRect(x: (externalWidth - internalWidth) / 2, y: (externalHeight - internalHeight) / 2, width: internalWidth, height: internalHeight))
        internalView.layer.cornerRadius = [internalWidth, internalHeight].min()! / 2
        internalView.backgroundColor = .white
        addSubview(internalView)
        
        let label = UILabel(frame: CGRect(x: (externalWidth - sizeText.width) / 2, y: (externalHeight - sizeText.height) / 2, width: sizeText.width, height: sizeText.height))
        label.text = text
        label.font = font
        label.textColor = .black
        addSubview(label)
    }
}
