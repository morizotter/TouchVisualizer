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

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushToDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let cell = sender as? UITableViewCell {
                viewController.text = cell.detailTextLabel?.text
            }
        }
    }

    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Smooth scrolling!"
        cell.detailTextLabel?.text = "\(indexPath.row)"
        return cell
    }

    // MARK: - Actions

    @IBAction func rightBarButtonItemTapped(sender: AnyObject) {
        let alertAction = UIAlertAction(title: "Show Alert", style: .default, handler: { [unowned self] (alertAction) -> Void in
                let controller = UIAlertController(
                    title: "Alert",
                    message: "Even when alert shows, your tap is visible.",
                    preferredStyle: .alert
                )
                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
            })

        var startOrStopTitle = "Start Visualizer"
        if Visualizer.isEnabled() {
            startOrStopTitle = "Stop Visualizer"
        }
        let startOrStopAction = UIAlertAction(title: startOrStopTitle, style: .default, handler: { [unowned self] (alertAction) -> Void in
                if Visualizer.isEnabled() {
                    Visualizer.stop()
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                } else {
                    Visualizer.start()
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                }
            })

        let controller = UIAlertController(
            title: "ActionSheet",
            message: "Even when action sheet shows, your tap is visible.",
            preferredStyle: .actionSheet
        )
        controller.addAction(alertAction)
        controller.addAction(startOrStopAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}
