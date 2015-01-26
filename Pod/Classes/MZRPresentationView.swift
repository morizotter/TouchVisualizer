//
//  MZRPresentationView.swift
//  MZRPresentation
//
//  Created by MORITA NAOKI on 2015/01/24.
//  Copyright (c) 2015年 molabo. All rights reserved.
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
        MZRPresentationView.sharedInstance().handleEvnet(event)
        self.swizzledSendEvent(event)
    }
    
    func swizzledDescription() -> String {
        return self.swizzledDescription() + "; " + self.swizzlingMessage
    }
}

public class TouchView: UIImageView {
    weak var touch: UITouch?
}

public class MZRPresentationView: UIView {

    // MARK: - Properties
    
    private weak var application: UIApplication? {
        didSet {
            if self.enabled {
                if let window = application?.keyWindow? {
                    if oldValue?.keyWindow === window {
                        for subview in self.subviews {
                            subview.removeFromSuperview()
                        }
                    }
                    window.swizzle()
                    window.addSubview(self)
                }
            }
        }
    }
    private var enabled = false
    private var image: UIImage?
    private var color: UIColor?
    private var touchViewSize = CGSizeMake(60.0, 60.0)
    private var touchViews = [TouchView]()
    
    // MARK: - Life Cycle
    
    class func sharedInstance() -> MZRPresentationView {
        struct Static {
            static let instance : MZRPresentationView = MZRPresentationView()
        }
        return Static.instance
    }
    
    private override init() {
        super.init()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChangeNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applicationDidBecomeActiveNotification(notification: NSNotification) {
        self.application = notification.object as UIApplication?
    }
    
    func orientationDidChangeNotification(notification: NSNotification) {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: - Methods
    
    public class func start() {
        self.start(nil, image: nil)
    }
    public class func start(color: UIColor?, image: UIImage?) {
        let instance = self.sharedInstance()
        instance.enabled = true
        instance.color = color
        
        if (image != nil) {
            instance.image = image
        } else {
            let color = instance.color ?? UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8)
            let rect = CGRectMake(0, 0, instance.touchViewSize.width, instance.touchViewSize.height);
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            let contextRef = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(contextRef, color.CGColor)
            CGContextFillEllipseInRect(contextRef, rect);
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            instance.image = image;
        }
        image?.imageWithRenderingMode(.AlwaysTemplate)
        
        if let window = instance.application?.keyWindow {
            for subview in instance.subviews {
                subview.removeFromSuperview()
            }
            window.swizzle()
            window.addSubview(instance)
        }
    }
    
    public class func stop() {
        let instance = self.sharedInstance()
        instance.enabled = false
        instance.removeFromSuperview()
    }
    
    public func handleEvnet(event: UIEvent) {
        
        if event.type != UIEventType.Touches {
            return
        }
        
        if ((event.allTouches() != nil) && event.allTouches()!.count == 0) {
            for subview in self.subviews {
                removeFromSuperview()
            }
        }
        
        func createTouchView(touch: UITouch) -> UIImageView {
            let view = TouchView(frame: CGRectMake(0.0, 0.0, self.touchViewSize.width, self.touchViewSize.height))
            view.touch = touch
            view.image = self.image
            view.tintColor = self.color
            self.touchViews.append(view)
            return view
        }
        
        func findTouchView(touch: UITouch) -> TouchView? {
            for view in self.touchViews {
                if view.touch == touch {
                    return view
                }
            }
            return nil
        }
        
        for touch in event.allTouches()?.allObjects as [UITouch] {
            
            let phase = touch.phase
            switch phase {
            case .Began:
                let view = createTouchView(touch)
                view.center = touch.locationInView(self)
                self.addSubview(view)
            case .Moved:
                if let view = findTouchView(touch) {
                    view.center = touch.locationInView(self)
                }
            case .Stationary:
                break
            case .Ended, .Cancelled:
                if let view = findTouchView(touch) {
                    let index = find(self.touchViews, view)
                    self.touchViews.removeAtIndex(index!)
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        view.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        view.removeFromSuperview()
                    })
                }
            }
        }
    }
}
