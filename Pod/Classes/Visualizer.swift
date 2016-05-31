//
//  TouchVisualizer.swift
//  TouchVisualizer
//

import UIKit

final public class Visualizer:NSObject {
    
    // MARK: - Public Variables
    static public let sharedInstance = Visualizer()
    private var enabled = false
    private var config: Configuration!
    private var touchViews = [TouchView]()
    private var previousLog = ""
    
    // MARK: - Object life cycle
    private override init() {
      super.init()
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: #selector(Visualizer.orientationDidChangeNotification(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: #selector(Visualizer.applicationDidBecomeActiveNotification(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        UIDevice
            .currentDevice()
            .beginGeneratingDeviceOrientationNotifications()
        
        warnIfSimulator()
    }
    
    deinit {
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self)
    }
    
    // MARK: - Helper Functions
    @objc internal func applicationDidBecomeActiveNotification(notification: NSNotification) {
        UIApplication.sharedApplication().keyWindow?.swizzle()
    }
    
    @objc internal func orientationDidChangeNotification(notification: NSNotification) {
        let instance = Visualizer.sharedInstance
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
}

extension Visualizer {
    public class func isEnabled() -> Bool {
        return sharedInstance.enabled
    }
    
    // MARK: - Start and Stop functions
    public class func start() {
        start(Configuration())
    }
    
    public class func start(config: Configuration) {
        let instance = sharedInstance
        instance.enabled = true
        instance.config = config
        
        if let window = UIApplication.sharedApplication().keyWindow {
            for subview in window.subviews {
                if let subview = subview as? TouchView {
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
    
    // MARK: - Dequeue and locating TouchViews and handling events
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
            if touch == view.touch {
                return view
            }
        }
        
        return nil
    }
    
    public func handleEvent(event: UIEvent) {
        if event.type != .Touches {
            return
        }
        
        if !Visualizer.sharedInstance.enabled {
            return
        }
        
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        for touch in event.allTouches()! {
            let phase = touch.phase
            
            switch phase {
            case .Began:
                let view = dequeueTouchView()
                view.config = Visualizer.sharedInstance.config
                view.touch = touch
                view.beginTouch()
                view.center = touch.locationInView(keyWindow)
                keyWindow.addSubview(view)
                log(touch)
            case .Moved:
                if let view = findTouchView(touch) {
                    view.center = touch.locationInView(keyWindow)
                }
                
                log(touch)
            case .Stationary:
                log(touch)
                break
            case .Ended, .Cancelled:
                if let view = findTouchView(touch) {
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void  in
                        view.alpha = 0.0
                        view.endTouch()
                        }, completion: { [unowned self] (finished) -> Void in
                            view.removeFromSuperview()
                            self.log(touch)
                        })
                }
                
                log(touch)
            }
        }
    }
}

extension Visualizer {
    public func warnIfSimulator() {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            print("[TouchVisualizer] Warning: TouchRadius doesn't work on the simulator because it is not possible to read touch radius on it.", terminator: "")
        #endif
    }
    
    // MARK: - Logging
    public func log(touch: UITouch) {
        if !config.showsLog {
            return
        }
        
        var ti = 0.0
        var viewLogs = [[String:String]]()
        for view in touchViews {
            var index = ""
            
            if view.superview != nil {
                index = "\(ti)"
                ti += 1
            }
            
            var phase: String!
            switch touch.phase {
            case .Began: phase = "B"
            case .Moved: phase = "M"
            case .Ended: phase = "E"
            case .Cancelled: phase = "C"
            case .Stationary: phase = "S"
            }
            
            let x = String(format: "%.02f", view.center.x)
            let y = String(format: "%.02f", view.center.y)
            let center = "(\(x), \(y))"
            let radius = String(format: "%.02f", touch.majorRadius)
            viewLogs.append(["index": index, "center": center, "phase": phase, "radius": radius])
        }
        
        var log = "TV: "
        for viewLog in viewLogs {
            
            if (viewLog["index"]!).characters.count == 0 {
                continue
            }
            
            let index = viewLog["index"]!
            let center = viewLog["center"]!
            let phase = viewLog["phase"]!
            let radius = viewLog["radius"]!
            log += "[\(index)]<\(phase)> c:\(center) r:\(radius)\t"
        }
        
        if log == previousLog {
            return
        }
        
        previousLog = log
        print(log, terminator: "")
    }
}