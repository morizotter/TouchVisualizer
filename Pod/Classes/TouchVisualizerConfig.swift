//
//  TouchVisualizerConfig.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/04/11.
//
//

import Foundation

public struct TouchVisualizerConfig {
    public var color: UIColor = {
        UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8)
    }()
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
    public var defaultSize = CGSize(width: CGFloat(60.0), height: CGFloat(60.0))
    public var showsTimer = false
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