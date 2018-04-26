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

    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var profileBlockView: UIView!
    @IBOutlet weak var nextGameLabel: UILabel!

    @IBOutlet weak var leaderboardButton: UIButton!
    var game: Game = Game()
    
    @IBOutlet weak var profileImageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileBlockView.layer.masksToBounds = true
        self.profileBlockView.layer.cornerRadius = 10
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = 10

        self.leaderboardButton.layer.masksToBounds = true
        self.leaderboardButton.layer.cornerRadius = 10

        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")
        print(profImage!)

        if let image = UIImage(named: profImage!){
            self.profileImageButton.setImage(image, for: .normal)
        }

        self.game.getCurrentGame { (success) in
            if (success){
                //check if game is in progress or has finished
                if (self.game.isActive && !self.game.hasFinished){
                    self.displayActiveGameMode()
                } else if (self.game.hasFinished) {
                    self.displayUpcomingGameMode()
                }
            }
        }
    }

    func initializeLandingPage() {
        let user = User(username: UserDefaults.standard.string(forKey: "username")!, coinBalance: 0.0)
    }

    func displayActiveGameMode (){
        self.nextGameLabel.text = "Game in progress: Ending at " + self.game.finishDate.description
    }


    func displayUpcomingGameMode() {
        self.nextGameLabel.text = "The next game starts at " + self.game.startDate.description
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
            self.present(leaderboardVC, animated: true, completion: nil)
            print("showing leaderboard")
        }
    }
    @IBAction func enterGamePressed(_ sender: Any) {
        
    }

}

