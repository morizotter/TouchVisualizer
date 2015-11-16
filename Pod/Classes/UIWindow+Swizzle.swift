//
//  UIWindow+Swizzle.swift
//  TouchVisualizer
//

import UIKit

extension UIWindow {
    public var swizzlingMessage: String {
        return "Method Swizzlings: sendEvent: and description"
    }
    
    public func swizzle() {
        let range = self.description.rangeOfString(swizzlingMessage, options: .LiteralSearch, range: nil, locale: nil)
        if (range?.startIndex != nil) {
            return
        }
        
        let sendEvent = class_getInstanceMethod(object_getClass(self), "sendEvent:")
        let swizzledSendEvent = class_getInstanceMethod(object_getClass(self), "swizzledSendEvent:")
        method_exchangeImplementations(sendEvent, swizzledSendEvent)
        
        let description: Method = class_getInstanceMethod(object_getClass(self), "description")
        let swizzledDescription: Method = class_getInstanceMethod(object_getClass(self), "swizzledDescription")
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