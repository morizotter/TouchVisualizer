//
//  TouchVisualizer.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/01/24.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

final public class TouchVisualizer {
    
    private var config: TouchVisualizerConfig!
    private var touchViews = [TouchView]()
    private var enabled:Bool = false
    
    static let sharedInstance = TouchVisualizer()
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChangeNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func applicationDidBecomeActiveNotification(notification: NSNotification) {
        UIApplication.sharedApplication().keyWindow?.swizzle()
    }
    
    @objc func orientationDidChangeNotification(notification: NSNotification) {
        let instance = TouchVisualizer.sharedInstance
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
    
    // MARK: - Methods
    public class func isEnabled() -> Bool {
        return sharedInstance.enabled
    }
    
    public class func start() {
        start(TouchVisualizerConfig())
    }
    
    public class func start(config: TouchVisualizerConfig) {
        
        let instance = sharedInstance
        instance.enabled = true
        instance.config = config
        if let window = UIApplication.sharedApplication().keyWindow {
            for subview in window.subviews {
                if (subview as? TouchView != nil) {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    public class func stop() {
        let instance = sharedInstance
        instance.enabled = false
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
    
    private func dequeueTouchView() -> TouchView {
        var touchView: TouchView?
        for view in touchViews {
            if view.superview == nil {
                touchView = view
                break
            }
        }
        
        if touchView == nil {
            touchView = TouchView()
            touchViews.append(touchView!)
        }
        
        return touchView!
    }
    
    private func findTouchView(touch: UITouch) -> TouchView? {
        for view in touchViews {
            if view.touch == touch {
                return view
            }
        }
        return nil
    }
    
    public func handleEvent(event: UIEvent) {
        
        if event.type != UIEventType.Touches {
            return
        }
        
        if(!TouchVisualizer.sharedInstance.enabled){
            return
        }
        
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        
        for touch in event.allTouches()! as! Set<UITouch> {
            
            let phase = touch.phase
            switch phase {
            case .Began:
                let view = dequeueTouchView()
                view.config = TouchVisualizer.sharedInstance.config
                view.touch = touch
                view.beginTouch()
                view.center = touch.locationInView(keyWindow)
                keyWindow.addSubview(view)
            case .Moved:
                if let view = findTouchView(touch) {
                    view.center = touch.locationInView(keyWindow)
                }
            case .Stationary:
                break
            case .Ended, .Cancelled:
                if let view = findTouchView(touch) {
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                        view.alpha = 0.0
                        view.endTouch()
                    }, completion: { (finished) -> Void in
                        view.removeFromSuperview()
                    });
                }
            }
        }
    }
}
