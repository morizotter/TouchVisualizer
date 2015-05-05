//
//  ViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit
import TouchVisualizer

class ViewController: UITableViewController {
    
    // MARK: - Life Cycle
    let colorList = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    var currentColorIndex:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize with config
        var newConfig = TouchVisualizerConfig()
            newConfig.color = colorList[currentColorIndex]
        
        TouchVisualizer.start(newConfig)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let cell = sender as? UITableViewCell {
                viewController.text = cell.textLabel?.text
            }
            
//            if(TouchVisualizer.isEnabled()) {
//                TouchVisualizer.stop()
//            } else {
                currentColorIndex++
                if(currentColorIndex >= colorList.count) { currentColorIndex = 0 }
                
                var config = TouchVisualizerConfig()
                config.color = colorList[currentColorIndex]
                config.showsTimer = true
                TouchVisualizer.start(config)

//            }
            
        }
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "Cell: \(indexPath.row)"
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func leftBarButtonItemTapped(sender: AnyObject) {
        let controller = UIAlertController(
            title: "Alert",
            message: "Even when alert shows, your tap is visible.",
            preferredStyle: .Alert
        )
        controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        let controller = UIAlertController(
            title: "ActionSheet",
            message: "Even when action sheet shows, your tap is visible.",
            preferredStyle: .ActionSheet
        )
        for i in 0..<3 {
            controller.addAction(UIAlertAction(title: "Action(\(i))", style: .Default, handler: nil))
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

