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
    
    @IBOutlet weak private var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let text = self.text {
            self.textLabel.text = "No.\(text) cell is tapped."
        }
    }
}
