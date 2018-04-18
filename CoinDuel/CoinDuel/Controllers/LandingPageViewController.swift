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

    override func viewDidLoad() {
        super.viewDidLoad()
        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        let profImage = UserDefaults.standard.string(forKey:"profileImage")

        profileImage.image = UIImage(named: profImage!)
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
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
}

