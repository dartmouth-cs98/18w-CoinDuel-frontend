//
//  SecondViewController.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/1/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var ViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewLabel.text = "Hello world"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
