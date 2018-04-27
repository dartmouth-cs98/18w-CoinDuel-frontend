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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    var game: Game = Game()
    let numberFormatter = NumberFormatter()
    var leaderboard: Leaderboard = Leaderboard()
    var place: Int = 0
    @IBOutlet weak var capcoinResultLabel: UILabel!
    @IBOutlet weak var resultsText: UILabel!

    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

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
    @IBAction func nextButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving Results VC")
            UserDefaults.standard.set(nil, forKey: "gameId")
        }
    }
}

