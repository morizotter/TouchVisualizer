//
//  ViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/05/06.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit
import TouchVisualizer

class ViewController: UITableViewController {

    // MARK: - Life Cycle
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushToDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let cell = sender as? UITableViewCell {
                viewController.text = cell.detailTextLabel?.text
            }
        }
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.textLabel?.text = "Smooth scrolling!"
        cell.detailTextLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        let alertAction = UIAlertAction(title: "Show Alert", style: .Default, handler:
            { [unowned self] (alertAction) -> Void in
                let controller = UIAlertController(
                    title: "Alert",
                    message: "Even when alert shows, your tap is visible.",
                    preferredStyle: .Alert
                )
                controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(controller, animated: true, completion: nil)
            }
        )
        
        var startOrStopTitle = "Start Visualizer"
        if Visualizer.isEnabled() {
            startOrStopTitle = "Stop Visualizer"
        }
        let startOrStopAction = UIAlertAction(title: startOrStopTitle, style: .Default, handler:
            { [unowned self] (alertAction) -> Void in
                if Visualizer.isEnabled() {
                    Visualizer.stop()
                    self.navigationItem.leftBarButtonItem?.enabled = false
                } else {
                    Visualizer.start()
                    self.navigationItem.leftBarButtonItem?.enabled = true
                }
            }
        )
        
        let controller = UIAlertController(
            title: "ActionSheet",
            message: "Even when action sheet shows, your tap is visible.",
            preferredStyle: .ActionSheet
        )
        controller.addAction(alertAction)
        controller.addAction(startOrStopAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
