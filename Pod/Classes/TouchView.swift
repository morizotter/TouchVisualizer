//
//  TouchView.swift
//  Pods
//
//  Created by MORITA NAOKI on 2015/01/27.
//
//

import UIKit

final public class TouchView: UIImageView {
    
    // MARK: - Properties
    
    weak var touch: UITouch?
    private var _config: TouchVisualizerConfig
    
    public var config: TouchVisualizerConfig{
        get{ return _config }
        set(value) {
            _config = value
            self.image = self.config.image
            self.image = self.image?.imageWithRenderingMode(.AlwaysTemplate)
            self.tintColor = self.config.color
            self.timerLabel.textColor = self.config.color
        }
    }
    
    private var previousRatio: CGFloat = 1.0
    private var startDate: NSDate?
    private weak var timer: NSTimer?
    private var lastTimeString: String!
    
    lazy var timerLabel: UILabel = {
        let size = CGSizeMake(200.0, 44.0)
        let bottom = 8.0 as CGFloat
        var label:UILabel = UILabel(frame: CGRect(
            x: -(size.width - CGRectGetWidth(self.frame)) / 2,
            y: -size.height - bottom,
            width: size.width,
            height: size.height
            )
        )
        label.font = UIFont(name: "Helvetica", size: 24.0)
        label.textAlignment = .Center
        self.addSubview(label)
        return label
    }()
    
    // MARK: - Life cycle
    
    convenience init() {
        self.init(frame:CGRectZero)
    }
    
    override init(frame: CGRect) {
        self._config = TouchVisualizerConfig()
        super.init(frame: frame)
        self.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: self._config.defaultSize)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
    func beginTouch() {
        self.alpha = 1.0
        self.timerLabel.alpha = 0.0
        self.layer.transform = CATransform3DIdentity
        self.previousRatio = 1.0
        self.frame = CGRect(origin: self.frame.origin, size: self._config.defaultSize)
        self.startDate = NSDate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 60.0, target: self, selector: "update:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        if self._config.showsTimer {
            self.timerLabel.alpha = 1.0
        }
        
        if self._config.showsTouchRadius {
            self.updateSize()
        }
    }
    
    func endTouch() {
        self.timer?.invalidate()
    }
    
    internal func update(timer: NSTimer) {
        if let startDate = self.startDate {
            let interval = NSDate().timeIntervalSinceDate(startDate)
            var timeString = "\(interval)"
            let range = "\(interval)".rangeOfString(".")
            if let range = range {
                let r = advance(range.startIndex, 3)
                timeString = timeString.substringToIndex(advance(range.startIndex, 3))
                
                self.timerLabel.text = timeString
            }
        }
        if self._config.showsTouchRadius {
            self.updateSize()
        }
    }
    
    // MARK: - Methods
    
    func updateSize() {
        if let touch = self.touch {
            let ratio = touch.majorRadius / self._config.defaultSize.width
            if ratio != self.previousRatio {
                self.layer.transform = CATransform3DMakeScale(ratio, ratio, 1.0)
                self.previousRatio = ratio
            }
        }
    }
}