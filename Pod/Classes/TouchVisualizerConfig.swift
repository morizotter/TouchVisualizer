//
//  TouchVisualizerConfig.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/04/11.
//
//

import UIKit

public struct TouchVisualizerConfig {
    
    /**
    Color of touch points.
    */
    public var color: UIColor? = UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8)
    
    /**
    Image of touch points.
    */
    public var image: UIImage? = {
        let rect = CGRectMake(0, 0, 60.0, 60.0);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(contextRef, UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8).CGColor)
        CGContextFillEllipseInRect(contextRef, rect);
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        image = image.imageWithRenderingMode(.AlwaysTemplate)
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
    
    /**
    Shows log. This will affect performance. Make sure showing logs only in development environment.
    */
    public var showsLog = false
    
    public init() {}
}