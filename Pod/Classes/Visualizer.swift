//
//  TouchVisualizer.swift
//  TouchVisualizer
//
//  Created by MORITA NAOKI on 2015/01/24.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import Foundation

final public class Visualizer {
    
    // MARK: - Public Variables
    static public let sharedInstance = Visualizer()
    public var enabled = false
    public var config: Configuration!
    public var touchViews = [TouchView]()
    public var previousLog = ""
    
    // MARK: - Object life cycle
    private init() {
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "orientationDidChangeNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "applicationDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
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
    @objc public func applicationDidBecomeActiveNotification(notification: NSNotification) {
        UIApplication.sharedApplication().keyWindow?.swizzle()
    }
    
    @objc public func orientationDidChangeNotification(notification: NSNotification) {
        let instance = Visualizer.sharedInstance
        for touch in instance.touchViews {
            touch.removeFromSuperview()
        }
    }
}
