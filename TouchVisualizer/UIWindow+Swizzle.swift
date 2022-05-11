//
//  UIWindow+Swizzle.swift
//  TouchVisualizer
//

import UIKit

fileprivate var isSwizzled = false

@available(iOSApplicationExtension, unavailable)
extension UIWindow {

    @available(iOS 8.0, *)
	public func swizzle() {
        guard isSwizzled == false else {
            return
        }

		let sendEvent = class_getInstanceMethod(
            object_getClass(self), 
            #selector(UIApplication.sendEvent(_:))
        )
		let swizzledSendEvent = class_getInstanceMethod(
            object_getClass(self), 
            #selector(UIWindow.swizzledSendEvent(_:))
        )
        method_exchangeImplementations(sendEvent!, swizzledSendEvent!)
        
        isSwizzled = true
    }
}

// MARK: - Swizzle
@available(iOSApplicationExtension, unavailable)
extension UIWindow {
    @objc public func swizzledSendEvent(_ event: UIEvent) {
        Visualizer.sharedInstance.handleEvent(event)
        swizzledSendEvent(event)
    }
}
