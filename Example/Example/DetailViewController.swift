//
//  DetailViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var text: String?
    
    weak var timer: Timer?
    
    @IBOutlet weak private var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let text = self.text {
            self.textLabel.text = "No.\(text) cell is tapped."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(logTouches(timer:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    // Example for getting current touches
    // * Caution: Touches here have been emmited before. For example `phase` is always `stationary`, 
    //   it WAS `moved` at the time emmited.
    //   So use `getTouches` func for limited debug purpose.
    //   If you want to know the exact value, please override `handleEvent:` in UIWindow+Swizzle.swift.
    @objc func logTouches(timer: Timer) {
        for (idx, touch) in Visualizer.getTouches().enumerated() {
            print("[\(idx)] location: \(touch.location(in: self.view))")
        }
    }
}
