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
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var profileBlockView: UIView!
    @IBOutlet weak var nextGameLabel: UILabel!
    @IBOutlet weak var capCoinBalanceLabel: UILabel!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var profileImageButton: UIButton!

    let user = User(username: UserDefaults.standard.string(forKey: "username"), coinBalance: 0.0)
    var game: Game = Game()
    let numberFormatter = NumberFormatter()

    var granularity = 20000

    override func viewDidLayoutSubviews(){
        self.imageViewGradient.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileBlockView.layer.masksToBounds = true
        self.profileBlockView.layer.cornerRadius = 10
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = 10
        self.leaderboardButton.layer.masksToBounds = true
        self.leaderboardButton.layer.cornerRadius = 10
        self.profileImageButton.layer.masksToBounds = true
        self.profileImageButton.layer.cornerRadius = 10

        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")

        // Number format
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if let image = UIImage(named: profImage!){
            self.profileImageButton.setImage(image, for: .normal)
        }

        self.initializeLandingPage()
    }

    func initializeLandingPage() {
        self.user.updateCoinBalance { (success) in
            if (success){
                self.capCoinBalanceLabel.text = "Current CapCoin Balance: " + self.numberFormatter.string(from: NSNumber(value: self.user.coinBalance))! + " CC"
            }
        }
        self.game.getCurrentGame { (success) in
            if (success){
                print("got game")
                self.displayActiveGameMode()

                //check if game is in progress or has finished
                if (self.game.isActive && !self.game.hasFinished){
                    self.displayActiveGameMode()
                } else if (self.game.hasFinished) {
                    self.displayActiveGameMode()
                }
            }
        }
    }

    func displayActiveGameMode (){
        self.nextGameLabel.text = "The current game is ending " + self.game.finishDate.description
        // show active game capcoin performance graph
    }

    func displayUpcomingGameMode() {
        self.nextGameLabel.text = "The next game starts at " + self.game.startDate.description
        //show alltime capcoin performance graph
    }

    @IBAction func onProfileImagePressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(gameVC, animated: true, completion: nil)
        
        // From https://stackoverflow.com/questions/29374235/facebook-sdk-4-0-ios-swift-log-a-user-out-programmatically
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function 
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
    @IBAction func enterGamePressed(_ sender: Any) {
        
    }

}

