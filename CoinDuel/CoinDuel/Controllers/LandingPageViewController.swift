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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var profileBlockView: UIView!
    @IBOutlet weak var nextGameTextField: UILabel!
    var game: Game = Game()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")

        profileImage.image = UIImage(named: profImage!)

        self.game.getCurrentGame { (success) in
            if (success){
                print(self.game.startDate)
            }
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

