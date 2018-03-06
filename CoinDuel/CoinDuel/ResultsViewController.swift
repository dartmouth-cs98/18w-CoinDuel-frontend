//
//  ResultsViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/23/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {
    
    var game: Game = Game()
    let numberFormatter = NumberFormatter()

    @IBOutlet weak var capcoinResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Number format
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        self.numberFormatter.minimumFractionDigits = 2
        self.numberFormatter.maximumFractionDigits = 2
        
        self.capcoinResultLabel.text = "You received " + self.numberFormatter.string(from: NSNumber(value: game.coinBalance))! + " CC"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

