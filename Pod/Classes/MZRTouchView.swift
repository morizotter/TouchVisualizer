//
//  MZRTouchView.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/01/27.
//
//

import UIKit

public class MZRTouchView: UIImageView {
    
    // MARK: - Properties
    
    weak var touch: UITouch?
    
    private var startDate: NSDate?
    private weak var timer: NSTimer?
    
    let defaultTintColor = UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8)
    let defaultImage: UIImage = {
        let rect = CGRectMake(0, 0, 60.0, 60.0);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(contextRef, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(contextRef, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        image.imageWithRenderingMode(.AlwaysTemplate)
        return image
        }()
    
    // MARK: - Life cycle
    
    convenience init(image: UIImage?, color: UIColor?) {
        self.init(frame: CGRectMake(0.0, 0.0, 60.0, 60.0))
        
        self.image = image ?? self.defaultImage
        self.image = self.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = color ?? self.defaultTintColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
    // MARK: - Methods
    
    func start() {
        self.startDate = NSDate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 60.0, target: self, selector: "update:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
    }
    
    func stop() {
        self.startDate = nil
        self.timer?.invalidate()
    }
    
    func update(timer: NSTimer) {
        if let startDate = self.startDate {
            let interval = NSDate().timeIntervalSinceDate(startDate)
            println("interval: \(interval)")
        }
    }
}