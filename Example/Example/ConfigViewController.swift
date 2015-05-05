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
    
    @IBOutlet weak var blueColorCell: UITableViewCell!
    @IBOutlet weak var redColorCell: UITableViewCell!
    @IBOutlet weak var greenColorCell: UITableViewCell!
    
    var config = TouchVisualizerConfig()
    
    let colors = [
        "blue": UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.8),
        "green": UIColor.greenColor(),
        "red": UIColor.redColor()
    ]
    
    // MARK: - Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TouchVisualizer.start()
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
            config.showsTouchRadius = !config.showsTouchRadius
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
        TouchVisualizer.start(config)
    }
    
    func updateCells() {
        let boolCells = [timerCell, touchRadiusCell]
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
        TouchVisualizer.start()
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

