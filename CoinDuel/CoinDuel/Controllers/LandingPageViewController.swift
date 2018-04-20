//
//  LandingPageViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 4/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit


class LandingPageViewController: UIViewController {


    @IBOutlet weak var UserLabel: UILabel!

    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var profileBlockView: UIView!
    @IBOutlet weak var nextGameTextField: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var leaderboardButton: UIButton!
    var game: Game = Game()
    
    @IBOutlet weak var profileImageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileBlockView.layer.masksToBounds = true
        self.profileBlockView.layer.cornerRadius = 10
        self.enterGameButton.layer.masksToBounds = true
        self.enterGameButton.layer.cornerRadius = 10
        self.logoImageView.layer.masksToBounds = true
        self.logoImageView.layer.cornerRadius = 10
        self.leaderboardButton.layer.masksToBounds = true
        self.leaderboardButton.layer.cornerRadius = 10

        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")

        self.profileImageButton.imageView?.image = UIImage(named: profImage!)

        self.game.getCurrentGame { (success) in
            if (success){
                print(self.game.startDate)
            }
        }

    }

    @IBAction func onProfileImagePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let leaderboardVC = storyboard.instantiateViewController(withIdentifier: "LeaderboardViewController") as? LeaderboardViewController {
            self.present(leaderboardVC, animated: true, completion: nil)
            print("showing leaderboard")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func enterGamePressed(_ sender: Any) {
        
    }
    @IBAction func logoutPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(gameVC, animated: true, completion: nil)
    }
}

