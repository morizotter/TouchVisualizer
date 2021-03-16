//
//  UIApplication+Swizzle.swift
//  TouchVisualizer
//

import UIKit

// MARK: - Swizzle
extension UIApplication {
    
    static func swizzle() {
        guard let sendEvent = class_getInstanceMethod(UIApplication.self, #selector(sendEvent(_:))),
              let swizzledSendEvent = class_getInstanceMethod(UIApplication.self, #selector(swizzledSendEvent(_:)))
        else { return }
        method_exchangeImplementations(sendEvent, swizzledSendEvent)
    }
    
    @objc func swizzledSendEvent(_ event: UIEvent) {
        Visualizer.sharedInstance.handleEvent(event)
        swizzledSendEvent(event)
    }
}
