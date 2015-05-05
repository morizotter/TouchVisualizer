//
//  UIWindow.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/01/27.
//
//

import UIKit

public extension UIWindow {
    
    var swizzlingMessage: String {
        return "Method Swizzlings: sendEvent: and description"
    }
    
    func swizzle() {
        
        var range = self.description.rangeOfString(self.swizzlingMessage, options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
        if (range?.startIndex != nil) {
            return;
        }
        
        var sendEvent: Method = class_getInstanceMethod(object_getClass(self), "sendEvent:")
        var swizzledSendEvent: Method = class_getInstanceMethod(object_getClass(self), "swizzledSendEvent:")
        method_exchangeImplementations(sendEvent, swizzledSendEvent)
        
        var description: Method = class_getInstanceMethod(object_getClass(self), "description")
        var swizzledDescription: Method = class_getInstanceMethod(object_getClass(self), "swizzledDescription")
        method_exchangeImplementations(description, swizzledDescription)
    }
    
    func swizzledSendEvent(event: UIEvent) {
        TouchVisualizer.sharedInstance.handleEvent(event)
        self.swizzledSendEvent(event)
    }
    
    func swizzledDescription() -> String {
        return self.swizzledDescription() + "; " + self.swizzlingMessage
    }
}