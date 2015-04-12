//
//  MZRPresentationConfig.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/04/11.
//
//

import Foundation

public struct MZRPresentationConfig {
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
    public init() {}
    public mutating func setColor(color: UIColor) {
        self.color = color
    }
    public mutating func setImage(image: UIImage) {
        self.image = image
    }
}