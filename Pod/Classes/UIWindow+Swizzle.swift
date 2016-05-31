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
        
        let sendEvent = class_getInstanceMethod(object_getClass(self), #selector(UIApplication.sendEvent(_:)))
        let swizzledSendEvent = class_getInstanceMethod(object_getClass(self), #selector(UIWindow.swizzledSendEvent(_:)))
        method_exchangeImplementations(sendEvent, swizzledSendEvent)
        
        let description: Method = class_getInstanceMethod(object_getClass(self), #selector(NSObject.description as () -> String))
        let swizzledDescription: Method = class_getInstanceMethod(object_getClass(self), #selector(UIWindow.swizzledDescription))
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