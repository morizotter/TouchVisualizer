//
//  ConfigViewController.swift
//  Example
//
//  Created by MORITA NAOKI on 2015/01/25.
//  Copyright (c) 2015年 molabo. All rights reserved.
//

import UIKit
import TouchVisualizer

final class ConfigViewController: UITableViewController {
    
    @IBOutlet weak var timerCell: UITableViewCell!
    @IBOutlet weak var touchRadiusCell: UITableViewCell!
    @IBOutlet weak var logCell: UITableViewCell!
    
    @IBOutlet weak var blueColorCell: UITableViewCell!
    @IBOutlet weak var redColorCell: UITableViewCell!
    @IBOutlet weak var greenColorCell: UITableViewCell!
    
    var config = Configuration()
    
    let colors = [
        "blue": UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8),
        "green": UIColor(red: 22/255.0, green: 160/255.0, blue: 133/255.0, alpha: 0.8),
        "red": UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 0.8)
    ]
    
    // MARK: - Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Visualizer.start()
        updateCells()
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell == timerCell {
            config.showsTimer = !config.showsTimer
        }
        if cell == touchRadiusCell {
            if isSimulator() {
                let controller = UIAlertController(
                    title: "Warning",
                    message: "This property doesn't work on the simulator because it is not possible to read touch radius on it. Please test it on device.",
                    preferredStyle: .Alert
                )
                controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(controller, animated: true, completion: nil)
                return
            }
            config.showsTouchRadius = !config.showsTouchRadius
        }
        if cell == logCell {
            config.showsLog = !config.showsLog
        }
        if cell == blueColorCell {
            config.color = colors["blue"]!
        }
        if cell == redColorCell {
            config.color = colors["red"]!
        }
        if cell == greenColorCell {
            config.color = colors["green"]!
        }
        
        updateCells()
        Visualizer.start(config)
    }
    
    func updateCells() {
        let boolCells = [timerCell, touchRadiusCell, logCell]
        for cell in boolCells {
            cell.detailTextLabel?.text = "false"
        }
        let checkmarkCells = [blueColorCell, redColorCell, greenColorCell]
        for cell in checkmarkCells {
            cell.accessoryType = .None
        }
        
        if config.showsTimer {
            timerCell.detailTextLabel?.text = "true"
        }
        if config.showsTouchRadius {
            touchRadiusCell.detailTextLabel?.text = "true"
        }
        if config.showsLog {
            logCell.detailTextLabel?.text = "true"
        }
        if config.color == colors["blue"] {
            blueColorCell.accessoryType = .Checkmark
        }
        else if config.color == colors["red"] {
            redColorCell.accessoryType = .Checkmark
        }
        else if config.color == colors["green"] {
            greenColorCell.accessoryType = .Checkmark
        }
    }
    
    // MARK: - Actions

    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
        Visualizer.start()
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isSimulator() -> Bool {
        var simulator = false
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            simulator = true
        #endif
        return simulator
    }
}

