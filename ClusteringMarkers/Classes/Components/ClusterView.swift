//
//  ClusterView.swift
//  Created by Aleksandr Smorodov on 22.5.18.
//

import UIKit

open class ClusterView: UIView {
    
    open var maxLimitCount: UInt {
        return 100
    }
    open var minLimitCount: UInt {
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
    
    open var minMargin: Double {
        return 5
    }
    
    public var displayedLabel = UILabel()
    
    public var number: UInt?
    public var displayedText: String?
    
    public convenience init(number: UInt, displayedText: String) {
        self.init(frame: .zero)
        
        self.number = number
        self.displayedText = displayedText
        
        frame = getRect()
        addSubview(displayedLabel)
        
        styleView()
        styleLabel()
    }
    
    open func styleView() {
        
        backgroundColor = UIColor.white
        layer.cornerRadius = bounds.size.width / 2
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
    }
    
    open func styleLabel() {
        
        displayedLabel.frame = frame
        displayedLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        displayedLabel.textAlignment = .center
        displayedLabel.backgroundColor = UIColor.clear
        displayedLabel.adjustsFontSizeToFitWidth = true
        displayedLabel.minimumScaleFactor = 2
        displayedLabel.numberOfLines = 1
        displayedLabel.baselineAdjustment = .alignCenters
        displayedLabel.font = font
        displayedLabel.textColor = UIColor.black
        displayedLabel.text = displayedText
    }
    
    open var font: UIFont {
        return UIFont.systemFont(ofSize: getFontSize())
    }
    
    public func getRect() -> CGRect {
        
        guard let number = number else {
            return .zero
        }
        
        let size: CGSize
        
        switch number {
        case maxLimitCount...UInt.max:
            size = CGSize(width: maxDiametr, height: maxDiametr)
        case minLimitCount...maxLimitCount:
            let diametr = getSize(minSize: minDiametr, maxSize: maxDiametr)
            size = CGSize(width: diametr, height: diametr)
        default:
            size = CGSize(width: minDiametr, height: minDiametr)
        }
        
        if let minWidth = displayedText?.size(withAttributes: [NSAttributedString.Key.font: font]).width {
            
            let diametr = minWidth + CGFloat(minMargin * 2)
            if diametr > size.width {
                return CGRect(origin: .zero, size: CGSize(width: diametr, height: diametr))
            }
        }
        
        return CGRect(origin: .zero, size: size)
    }
    
    public func getFontSize() -> CGFloat {
        guard let number = number else {
            return CGFloat(minFont)
        }
        
        switch number {
        case maxLimitCount...UInt.max:
            return CGFloat(maxFont)
        case minLimitCount...maxLimitCount:
            return CGFloat(getSize(minSize: minFont, maxSize: maxFont))
        default:
            return CGFloat(minFont)
        }
    }
    
    private func getSize(minSize: Double, maxSize: Double) -> Double {
        guard let number = number else {
            return minSize
        }
        
        let p1 = (maxSize - minSize) * Double(number)
        let p2 = (Double(maxLimitCount) * minSize - Double(minLimitCount) * maxSize)
        
        return (p1 + p2) / (Double(maxLimitCount) - Double(minLimitCount))
    }
}
