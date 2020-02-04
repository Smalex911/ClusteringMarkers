//
//  ClusterViewConfiguration.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit

open class ClusterViewConfiguration {
    
    open var maxLimitCount: Double {
        return 50
    }
    open var minLimitCount: Double {
        return 3
    }
    
    open var maxDiametr: Double {
        return 40
    }
    open var minDiametr: Double {
        return 20
    }
    
    open var maxFont: Double {
        return 15
    }
    open var minFont: Double {
        return 12
    }
    
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
        case maxLimitCount...Double.infinity:
            return CGRect(x: 0, y: 0, width: maxDiametr, height: maxDiametr)
        case minLimitCount...maxLimitCount:
            let size = getSize(number: number, minSize: minDiametr, maxSize: maxDiametr)
            return CGRect(x: 0.0, y: 0.0, width: size, height: size)
        default:
            return CGRect(x: 0, y: 0, width: minDiametr, height: minDiametr)
        }
    }
    
    public func getFontSize(number: Double) -> CGFloat {
        switch number {
        case maxLimitCount...Double.infinity:
            return CGFloat(maxFont)
        case minLimitCount...maxLimitCount:
            return CGFloat(getSize(number: number, minSize: minFont, maxSize: maxFont))
        default:
            return CGFloat(minFont)
        }
    }
    
    private func getSize(number: Double, minSize: Double, maxSize: Double) -> Double {
        return ((maxSize - minSize) * number + (maxLimitCount * minSize - minLimitCount * maxSize)) / (maxLimitCount - minLimitCount)
    }
}
