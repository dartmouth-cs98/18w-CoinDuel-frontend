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
    
    @IBOutlet weak var capcoinResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.capcoinResultLabel.text = "You received " + String(self.game.totalReturn()) + " CapCoin"
        
        self.game.resultsViewed() { (completion) -> Void in
            if !completion {
                print("Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

