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
    var leaderboard: Leaderboard = Leaderboard()
    var place: Int = 0
    @IBOutlet weak var capcoinResultLabel: UILabel!
    @IBOutlet weak var resultsText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.game.id)
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "username")

        // Number format
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        self.numberFormatter.minimumFractionDigits = 2
        self.numberFormatter.maximumFractionDigits = 2
        self.leaderboard.getLeaderboardForGame(gameID: self.game.id) { (success) in
            if (success){
                var numPlayers = self.leaderboard.currentUsers.count.description
                for user in self.leaderboard.currentUsers {
                    self.place += 1
                    if (user.username == username!){
                        break
                    }
                }

                self.resultsText.text = "You came in " + self.place.description + " out of " + numPlayers + " users!"
            }
        }

        self.capcoinResultLabel.text = "You received " + self.numberFormatter.string(from: NSNumber(value: game.coinBalance))! + " CC"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

