//
//  ConfigViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit
import TouchVisualizer

class ConfigViewController: UITableViewController {
    
    @IBOutlet weak var startAndStopCell: UITableViewCell!
    @IBOutlet weak var blueColorCell: UITableViewCell!
    @IBOutlet weak var redColorCell: UITableViewCell!
    @IBOutlet weak var greenColorCell: UITableViewCell!
    
    let colors = [
        "blue": UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8),
        "green": UIColor.greenColor(),
        "redColor": UIColor.redColor()
    ]
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TouchVisualizer.start()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ToDetail" {
//            let viewController = segue.destinationViewController as! DetailViewController
//            if let cell = sender as? UITableViewCell {
//                viewController.text = cell.textLabel?.text
//            }
//            
////            if(TouchVisualizer.isEnabled()) {
////                TouchVisualizer.stop()
////            } else {
//                currentColorIndex++
//                if(currentColorIndex >= colorList.count) { currentColorIndex = 0 }
//                
//                var config = TouchVisualizerConfig()
//                config.color = colorList[currentColorIndex]
//                config.showsTimer = true
//                config.showsTouchRadius = true
//                TouchVisualizer.start(config)
//
////            }
//            
//        }
//    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let isStartAndStop = self.startAndStopCell == cell
        let isBlueColor = self.blueColorCell == cell
        let isRedColor = self.redColorCell == cell
        let isGreenColor = self.greenColorCell == cell
        
        if isStartAndStop {
            if TouchVisualizer.isEnabled() {
                TouchVisualizer.stop()
            } else {
                TouchVisualizer.start()
            }
        }
        
        self.updateCells()
    }
    
    func updateCells() {
        if TouchVisualizer.isEnabled() {
            self.startAndStopCell.textLabel?.text = "Stop"
        } else {
            self.startAndStopCell.textLabel?.text = "Start"
        }
    }
    
    // MARK: - Actions

    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

