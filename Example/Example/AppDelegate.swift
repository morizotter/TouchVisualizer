//
//  AppDelegate.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	func applicationDidFinishLaunching(_ application: UIApplication) {

		// It's the simpest way!
        Visualizer.start()
		
        // Initialize with config - octocat
//		var config = Configuration()
//		config.color = UIColor.black
//		config.showsTimer = true
//		config.showsTouchRadius = true
//		config.showsLog = true
//		config.image = UIImage(named: "octocat")
//		Visualizer.start(config)
	}
}

