//
//  TouchVisualizerConfig.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/04/11.
//
//

import Foundation

public struct TouchVisualizerConfig {
    
    /**
    Color of touch points.
    */
    public var color: UIColor = {
        UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8)
    }()
    
    /**
    Image of touch points.
    */
    public var image: UIImage = {
        let rect = CGRectMake(0, 0, 60.0, 60.0);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(contextRef, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(contextRef, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        image.imageWithRenderingMode(.AlwaysTemplate)
        return image
        }()
    
    /**
    Default touch point size. If `showsTouchRadius` is enabled, this value is ignored.
    */
    public var defaultSize = CGSize(width: CGFloat(60.0), height: CGFloat(60.0))
    
    /**
    Shows touch duration.
    */
    public var showsTimer = false
    
    /**
    Shows touch radius. It doesn't work on simulator because it is not possible to read touch radius on it. Please test it on device.
    */
    public var showsTouchRadius = false
    
    public init() {}
    public mutating func setColor(color: UIColor) {
        self.color = color
    }
    public mutating func setImage(image: UIImage) {
        self.image = image
    }
    public mutating func setShowsTimer(shows: Bool) {
        self.showsTimer = shows
    }
    public mutating func setShowsTouchRadius(shows: Bool) {
        self.showsTouchRadius = shows
    }
    public mutating func setDefaultSize(size: CGSize) {
        var newSize = size
        if size.width != size.height {
            if newSize.width > newSize.height {
                newSize.height = newSize.width
            } else {
                newSize.width = newSize.height
            }
        }
        self.defaultSize = newSize
    }
}