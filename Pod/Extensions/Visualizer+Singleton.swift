//
//  Visualizer+Singleton.swift
//  TouchVisualizer
//
//  Created by Douglas Bumby on 2015-06-02.
//  Copyright (c) 2015 molabo. All rights reserved.
//

import Foundation

// MARK: - Visualizer+Singleton
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
            if nil == view.superview {
                touchView = view
                break
            }
        }

        if nil == touchView {
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
        if .Touches != event.type {
            return
        }

        if !Visualizer.sharedInstance.enabled {
            return
        }

        let keyWindow = UIApplication.sharedApplication().keyWindow!
        for touch in event.allTouches()! as! Set<UITouch> {
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
                        UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: { [unowned self] () -> Void  in
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
