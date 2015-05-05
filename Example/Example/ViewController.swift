//
//  ViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/05/06.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let cell = sender as? UITableViewCell {
                viewController.text = cell.textLabel?.text
            }
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
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        let controller = UIAlertController(
            title: "ActionSheet",
            message: "Even when action sheet shows, your tap is visible.",
            preferredStyle: .ActionSheet
        )
        for i in 0..<3 {
            controller.addAction(UIAlertAction(title: "Alert(\(i))", style: .Default, handler: { [unowned self] (alertAction) -> Void in
                let controller = UIAlertController(
                    title: "Alert",
                    message: "Even when alert shows, your tap is visible.",
                    preferredStyle: .Alert
                )
                controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(controller, animated: true, completion: nil)
                }))
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
