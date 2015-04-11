//
//  MZRPresentationConfig.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/04/11.
//
//

import Foundation

public struct MZRPresentationConfig {
    public var color: UIColor?
    public var image: UIImage?
    public init() {}
    public mutating func setColor(color: UIColor?) {
        self.color = color
    }
    public mutating func setImage(image: UIImage?) {
        self.image = image
    }
}