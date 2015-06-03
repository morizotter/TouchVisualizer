//
//  Visualizer+Simulator.swift
//  TouchVisualizer
//
//  Created by Douglas Bumby on 2015-06-02.
//  Copyright (c) 2015 molabo. All rights reserved.
//

import Foundation

extension Visualizer {
    public func warnIfSimulator() {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            println("[TouchVisualizer] Warning: TouchRadius doesn't work on the simulator because it is not possible to read touch radius on it.")
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
                ++ti
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
            
            if 0 == count(viewLog["index"]!) {
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
        println(log)
    }
}