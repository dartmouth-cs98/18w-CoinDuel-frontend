//
//  ProfileViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/19/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var OldPassword: UITextField!
    @IBOutlet weak var NewPassword: UITextField!
    
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var NewUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserLabel.text = UserDefaults.standard.string(forKey:"username")
    }
    
    @IBOutlet weak var UserLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }

}
