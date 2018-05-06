//
//  UIWindow+Swizzle.swift
//  TouchVisualizer
//

import UIKit

fileprivate var isSwizzled = false

@available(iOS 8.0, *)
extension UIWindow {
	
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
        
        let pushEvent = class_getInstanceMethod(
            UINavigationController.classForCoder(), 
            #selector(UINavigationController.pushViewController(_:animated:))
        )
        let swizzledPushEvent = class_getInstanceMethod(
            UINavigationController.classForCoder(), 
            #selector(UINavigationController.swizzledPushViewController(_:animated:))
        )
        method_exchangeImplementations(pushEvent!, swizzledPushEvent!)
        
        isSwizzled = true
    }
}

// MARK: - Swizzle
extension UIWindow {
    @objc public func swizzledSendEvent(_ event: UIEvent) {
        Visualizer.sharedInstance.handleEvent(event)
        swizzledSendEvent(event)
    }
}

extension UINavigationController {
    @objc public func swizzledPushViewController(_ viewController: UIViewController, animated: Bool) {
        Visualizer.sharedInstance.removeAllTouchViews()
        swizzledPushViewController(viewController, animated: animated)
    }
}
