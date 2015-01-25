//
//  ViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
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
            let viewController = segue.destinationViewController as DetailViewController
            if let cell = sender as? UITableViewCell {
                viewController.text = "\(cell.textLabel?.text)"
            }
        }
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Cell: \(indexPath.row)"
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        let controller = UIAlertController(
            title: "ActionSheet",
            message: "In this case, your tap is visible.",
            preferredStyle: .ActionSheet
        )
        for i in 0..<4 {
            controller.addAction(UIAlertAction(title: "Action(\(i))", style: .Default, handler: nil))
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

