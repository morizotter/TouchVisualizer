//
//  MZRPresentationView.swift
//  MZRPresentation
//
//  Created by MORITA NAOKI on 2015/01/24.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

public class MZRPresentationView: UIView {

    // MARK: - Properties
    private var enabled = false
    private var image: UIImage?
    private var color: UIColor?
    private var touchViewSize = CGSizeMake(60.0, 60.0)
    private var touchViews = [MZRTouchView]()
    
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
        UIApplication.sharedApplication().keyWindow?.swizzle()
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

        if let window = UIApplication.sharedApplication().keyWindow {
            for subview in window.subviews {
                if (subview as? MZRTouchView != nil) {
                    subview.removeFromSuperview()
                }
            }
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
        
        func createTouchView(touch: UITouch) -> UIImageView {
            let view = MZRTouchView(frame: CGRectMake(0.0, 0.0, self.touchViewSize.width, self.touchViewSize.height))
            view.touch = touch
            view.image = self.image
            view.tintColor = self.color
            self.touchViews.append(view)
            return view
        }
        
        func findTouchView(touch: UITouch) -> MZRTouchView? {
            for view in self.touchViews {
                if view.touch == touch {
                    return view
                }
            }
            return nil
        }
        
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        
        for touch in event.allTouches()?.allObjects as [UITouch] {
            
            let phase = touch.phase
            switch phase {
            case .Began:
                let view = createTouchView(touch)
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
                    let index = find(self.touchViews, view)
                    self.touchViews.removeAtIndex(index!)
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { () -> Void in
                        view.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        view.removeFromSuperview()
                    });
                }
            }
        }
    }
}
