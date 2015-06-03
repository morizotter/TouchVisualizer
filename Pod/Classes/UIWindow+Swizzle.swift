//
//  UIWindow+Swizzle.swift
//  TouchVisualizer
//
//  Created by MORITA NAOKI on 2015/01/27.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

public extension UIWindow {
    public var swizzlingMessage: String {
        return "Method Swizzlings: sendEvent: and description"
    }
    
    public func swizzle() {
        var range = self.description.rangeOfString(swizzlingMessage, options: .LiteralSearch, range: nil, locale: nil)
        if (range?.startIndex != nil) {
            return
        }
        
        var sendEvent = class_getInstanceMethod(object_getClass(self), "sendEvent:")
        var swizzledSendEvent = class_getInstanceMethod(object_getClass(self), "swizzledSendEvent:")
        method_exchangeImplementations(sendEvent, swizzledSendEvent)
        
        var description: Method = class_getInstanceMethod(object_getClass(self), "description")
        var swizzledDescription: Method = class_getInstanceMethod(object_getClass(self), "swizzledDescription")
        method_exchangeImplementations(description, swizzledDescription)
    }
    
    public func swizzledSendEvent(event: UIEvent) {
        Visualizer.sharedInstance.handleEvent(event)
        swizzledSendEvent(event)
    }
    
    public func swizzledDescription() -> String {
        return swizzledDescription() + "; " + swizzlingMessage
    }
}