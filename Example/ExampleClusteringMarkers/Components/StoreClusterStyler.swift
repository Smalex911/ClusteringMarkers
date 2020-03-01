//
//  StoreClusterStyler.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 28.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import YandexMapKit

struct StoreClusterStyler {
    
    static func clusterImage(_ clusterSize: UInt) -> UIImage? {
        return image(clusterSize)
    }

    static func clusterView(_ clusterSize: UInt) -> UIView {
        return view(clusterSize)
    }
    
    static func clusterYRTView(_ clusterSize: UInt) -> YRTViewProvider {
        return YRTViewProvider(uiView: view(clusterSize))
    }
    
    static func view(_ clusterSize: UInt) -> UIView {
        
        let fontSize = CGFloat(15)
        let marginSize = CGFloat(8)
        let strokeSize = CGFloat(3)
        
        let scale = CGFloat(1)
        let text = (clusterSize as NSNumber).stringValue
        let font = UIFont.systemFont(ofSize: fontSize * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + marginSize * scale
        let externalRadius = internalRadius + strokeSize * scale
        
        let externalView = UIView(frame: CGRect(x: 0, y: 0, width: 2 * externalRadius, height: 2 * externalRadius))
        externalView.isOpaque = false
        externalView.backgroundColor = .red
        externalView.layer.cornerRadius = externalView.frame.width / 2
        
        let internalView = UIView(frame: CGRect(x: externalRadius - internalRadius, y: externalRadius - internalRadius, width: 2 * internalRadius, height: 2 * internalRadius))
        internalView.backgroundColor = .white
        internalView.layer.cornerRadius = internalView.frame.width / 2
        externalView.addSubview(internalView)
        
        let label = UILabel(frame: CGRect(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2, width: size.width, height: size.height))
        label.text = text
        label.font = font
        label.textColor = .black
        externalView.addSubview(label)
        
        return externalView
    }
    
    static func image(_ clusterSize: UInt) -> UIImage? {
        
        let fontSize = CGFloat(15)
        let marginSize = CGFloat(8)
        let strokeSize = CGFloat(3)
        
        let scale = CGFloat(1)
        let text = (clusterSize as NSNumber).stringValue
        let font = UIFont.systemFont(ofSize: fontSize * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + marginSize * scale
        let externalRadius = internalRadius + strokeSize * scale
        let iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)
        
        UIGraphicsBeginImageContext(iconSize)
        let ctx = UIGraphicsGetCurrentContext()!

        ctx.setFillColor(UIColor.red.cgColor)
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
