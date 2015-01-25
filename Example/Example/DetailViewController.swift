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
        self.textLabel.text = self.text
    }
}
