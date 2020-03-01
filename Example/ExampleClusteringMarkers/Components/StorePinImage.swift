//
//  StorePinImage.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 27.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class StorePinImage {
    
    static func image(text: String, isSelected: Bool) -> UIImage? {
        
        let fontSize = CGFloat(15)
        let marginSize = CGFloat(3)
        let strokeSize = CGFloat(3)
        
        let scale = UIScreen.main.scale
        let font = UIFont.systemFont(ofSize: fontSize * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + marginSize * scale
        let externalRadius = internalRadius + strokeSize * scale
        let iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)

        UIGraphicsBeginImageContext(iconSize)
        let ctx = UIGraphicsGetCurrentContext()!

        ctx.setFillColor(isSelected ? UIColor.black.cgColor : UIColor.red.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: .zero,
            size: CGSize(width: 2 * externalRadius, height: 2 * externalRadius)));

        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: CGPoint(x: externalRadius - internalRadius, y: externalRadius - internalRadius),
            size: CGSize(width: 2 * internalRadius, height: 2 * internalRadius)));

        (text as NSString).draw(
            in: CGRect(
                origin: CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2),
                size: size),
            withAttributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black])
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
