//
//  MZRPresentationView.swift
//  MZRPresentation
//
//  Created by MORITA NAOKI on 2015/01/24.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

final public class TouchVisualizer {
    
    private var config: TouchVisualizerConfig!
    private var touchViews = [TouchView]()
    
    class func sharedInstance() -> TouchVisualizer {
        struct Static {
            static let instance : TouchVisualizer = TouchVisualizer()
        }
        return Static.instance
    }
    
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
        let instance = TouchVisualizer.sharedInstance()
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
    
    // MARK: - Methods
    
    public class func start() {
        self.start(TouchVisualizerConfig())
    }
    
    public class func start(config: TouchVisualizerConfig) {
        let instance = self.sharedInstance()
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
        let instance = self.sharedInstance()
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
    
    private func dequeueTouchView() -> TouchView {
        var touchView: TouchView?
        for view in self.touchViews {
            if view.superview == nil {
                touchView = view
                break
            }
        }
        
        if touchView == nil {
            touchView = TouchView(config: self.config)
            self.touchViews.append(touchView!)
        }
        
        return touchView!
    }
    
    private func findTouchView(touch: UITouch) -> TouchView? {
        for view in self.touchViews {
            if view.touch == touch {
                return view
            }
        }
        return nil
    }
    
    public func handleEvnet(event: UIEvent) {
        
        if event.type != UIEventType.Touches {
            return
        }
        
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        
        for touch in event.allTouches()! as! Set<UITouch> {
            
            let phase = touch.phase
            switch phase {
            case .Began:
                let view = self.dequeueTouchView()
                view.touch = touch
                view.start()
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
                    }, completion: { (finished) -> Void in
                        view.stop()
                        view.alpha = 1.0
                        view.removeFromSuperview()
                    });
                }
            }
        }
    }
}
