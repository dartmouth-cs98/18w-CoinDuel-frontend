//
//  LandingPageViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 4/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

import FacebookLogin
import FBSDKLoginKit
class LandingPageViewController: UIViewController {
    
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var imageViewGradient: UIImageView!
    @IBOutlet weak var profileBlockView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var capCoinBalanceLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    @IBOutlet weak var enterButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var balanceActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rankActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    let user = User(username: UserDefaults.standard.string(forKey: "username"), coinBalance: 0.0, rank: 0, profilePicture: "profile")
    var game: Game = Game()
    let numberFormatter = NumberFormatter()

    var granularity = 20000

    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        // background gradient
        self.imageViewGradient.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.enterGameButton.isHidden = true

        self.profileBlockView.layer.masksToBounds = true
        self.profileBlockView.layer.cornerRadius = 10
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = self.enterGameButton.frame.height / 2
        self.leaderboardButton.layer.masksToBounds = true
        self.leaderboardButton.layer.cornerRadius = self.leaderboardButton.frame.height / 2
        self.profileButton.layer.masksToBounds = true
        self.profileButton.layer.cornerRadius = self.leaderboardButton.frame.height / 2
        
        self.leaderboardButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.5).cgColor
        self.leaderboardButton.layer.borderWidth = 0.75
        self.profileButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.5).cgColor
        self.profileButton.layer.borderWidth = 0.75

        // load user data from defaults
        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")

        // Number format
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        // display profile image
        self.profileImage.image = UIImage(named: profImage!)
        
        // dynamic instantiation
        self.initializeLandingPage()
    }

    func initializeLandingPage() {
        // Retrieve gameId (if we already have it)
        let storedGameId = UserDefaults.standard.string(forKey: "gameId")
        // set rank view
        self.user.updateRankAllTime { (success) in
            if (success){
                self.rankLabel.text = String(self.user.rank) + " of " + String(self.user.otherUsers)
            }
            self.rankActivityIndicator.isHidden = true
        }
        
        // set coin balance view
        self.user.updateCoinBalance { (success) in
            if (success){
                self.capCoinBalanceLabel.text = self.numberFormatter.string(from: NSNumber(value: self.user.coinBalance))! + " CC"

                // set game views
                self.game.getCurrentGame { (success) in
                    if (success){
                        print("got game")

                        if self.user.lastGameId != "nogame" && self.game.id != self.user.lastGameId {
                            // Display results pop up if the user had an entry
                            let resultsGame = Game()
                            resultsGame.id = self.user.lastGameId
                            resultsGame.getEntry() { (entryStatus) -> Void in
                                if entryStatus == "entry" {

                                    // display results view
                                    let storyboard = UIStoryboard(name: "Results", bundle: nil)
                                    let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                                    resultsVC.game = resultsGame
                                    resultsVC.user = self.user
                                    self.present(resultsVC, animated: true, completion: nil)

                                } else {
                                    // Could not get results for this game
                                    print("No results available")
                                }
                            }
                        }

                        //check if game is in progress or has finished
                        if (self.game.isActive && !self.game.hasFinished){
                            self.displayActiveGameMode()
                        } else if (self.game.hasFinished) {
                            self.displayActiveGameMode()
                        } else {
                            self.displayUpcomingGameMode()
                        }
                    } else {
                        self.displayNoGameMode()
                    }
                }
            }
            self.balanceActivityIndicator.isHidden = true
        }

    }

    func displayActiveGameMode (){
        // set labels
        self.gameStatusLabel.text = "Game In Progress"
        self.gameTimeLabel.text = "Game ends " + self.game.finishDate.description
        self.enterButtonActivityIndicator.isHidden = true
        self.enterGameButton.isHidden = false
        
        // set button
        self.enterGameButton.setTitle("Enter Game", for: .normal)
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = self.enterGameButton.frame.height / 2
//        self.enterGameButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.5).cgColor
//        self.enterGameButton.layer.borderWidth = 0.75
        
        // show active game capcoin performance graph
    }

    func displayUpcomingGameMode() {
        // set labels
        self.gameStatusLabel.text = "Next Game"
        self.gameTimeLabel.numberOfLines = 0
        self.gameTimeLabel.text = self.game.startDate.description
        self.enterButtonActivityIndicator.isHidden = true
        self.enterGameButton.isHidden = false
        
        // set button
        self.enterGameButton.setTitle("Preview Game", for: .normal)
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = self.enterGameButton.frame.height / 2
//        self.enterGameButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.5).cgColor
//        self.enterGameButton.layer.borderWidth = 0.75
        
        //show alltime capcoin performance graph
    }
    
    func displayNoGameMode() {
        // set labels
        self.gameStatusLabel.text = "No games scheduled"
        self.gameTimeLabel.text = "Check back soon!"
        self.enterButtonActivityIndicator.isHidden = true
        
        //show alltime capcoin performance graph
    }
    
    /*
     * Present profile upon button press.
     */
    @IBAction func onLogoutPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // reset all user defaults except username
        dictionary.keys.forEach { key in
            if (key != "username") {
                defaults.removeObject(forKey: key)
            }
        }
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "EntryViewController") as UIViewController
        self.present(gameVC, animated: true, completion: nil)
        
        // From https://stackoverflow.com/questions/29374235/facebook-sdk-4-0-ios-swift-log-a-user-out-programmatically
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
    }

    @IBAction func onRefreshPressed(_ sender: Any) {
        // hide previously loaded stats
        self.enterGameButton.isHidden = true
        self.rankLabel.text = ""
        self.capCoinBalanceLabel.text = ""
        
        // show all activity indicators
        self.enterButtonActivityIndicator.isHidden = false
        self.rankActivityIndicator.isHidden = false
        self.balanceActivityIndicator.isHidden = false
        
        // init rest of landing page
        self.initializeLandingPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onLeaderboardPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let leaderboardVC = storyboard.instantiateViewController(withIdentifier: "LeaderboardViewController") as? LeaderboardViewController {
            leaderboardVC.game = self.game
            self.present(leaderboardVC, animated: true, completion: nil)
            print("showing leaderboard")
        }
    }
    
    @IBAction func unwindGameView(unwindSegue: UIStoryboardSegue) {
        print("Unwinding HERHEHHEHEHRHE")
        self.viewDidLoad()
    }


}

