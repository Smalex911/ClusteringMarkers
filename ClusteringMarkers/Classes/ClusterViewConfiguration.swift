//
//  ClusterViewConfiguration.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit

public class ClusterViewConfiguration {
    
    static var MAX_COUNT : Double = 50
    static var MIN_COUNT : Double = 3
    static var MAX_RECT_SIZE : Double = 40
    static var MIN_RECT_SIZE : Double = 20
    static var MAX_FONT_SIZE : Double = 15
    static var MIN_FONT_SIZE : Double = 12
    
    public var displayedLabel : UILabel?
    public var contentView : UIView?
    
    public init() { }
    
    public func getClusterImage(number: Double, displayedText: String) -> UIImage {
        let label = displayedLabel ?? getStandartStyledLabel(number: number, displayedText: displayedText)
        
        let cView = contentView ?? getStandartStyledContentView(number: number)
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(getRect(number: number).size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            cView.layer.render(in: context)
            label.layer.render(in: context)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func getStandartStyledLabel(number: Double, displayedText: String) -> UILabel {
        
        let label = UILabel(frame: getRect(number: number))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        label.font = label.font.withSize(getFontSize(number: number))
        label.textColor = UIColor.black
        label.text = displayedText
        
        return label
    }
    
    private func getStandartStyledContentView(number: Double) -> UIView {
        
        let contentView = UIView(frame: getRect(number: number))
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = contentView.bounds.size.width / 2
        
        return contentView
    }
    
    public  func getRect(number: Double) -> CGRect {
        switch number {
        case ClusterViewConfiguration.MAX_COUNT...Double.infinity:
            return CGRect(x: 0, y: 0, width: ClusterViewConfiguration.MAX_RECT_SIZE, height: ClusterViewConfiguration.MAX_RECT_SIZE)
        case ClusterViewConfiguration.MIN_COUNT...ClusterViewConfiguration.MAX_COUNT:
            let size = getSize(number: number, minSize: ClusterViewConfiguration.MIN_RECT_SIZE, maxSize: ClusterViewConfiguration.MAX_RECT_SIZE)
            return CGRect(x: 0.0, y: 0.0, width: size, height: size)
        default:
            return CGRect(x: 0, y: 0, width: ClusterViewConfiguration.MIN_RECT_SIZE, height: ClusterViewConfiguration.MIN_RECT_SIZE)
        }
    }
    
    public func getFontSize(number: Double) -> CGFloat {
        switch number {
        case ClusterViewConfiguration.MAX_COUNT...Double.infinity:
            return CGFloat(ClusterViewConfiguration.MAX_FONT_SIZE)
        case ClusterViewConfiguration.MIN_COUNT...ClusterViewConfiguration.MAX_COUNT:
            return CGFloat(getSize(number: number, minSize: ClusterViewConfiguration.MIN_FONT_SIZE, maxSize: ClusterViewConfiguration.MAX_FONT_SIZE))
        default:
            return CGFloat(ClusterViewConfiguration.MIN_FONT_SIZE)
        }
    }
    
    private func getSize(number: Double, minSize: Double, maxSize: Double) -> Double {
        return ((maxSize - minSize) * number + (ClusterViewConfiguration.MAX_COUNT * minSize - ClusterViewConfiguration.MIN_COUNT * maxSize)) / (ClusterViewConfiguration.MAX_COUNT - ClusterViewConfiguration.MIN_COUNT)
    }
}
