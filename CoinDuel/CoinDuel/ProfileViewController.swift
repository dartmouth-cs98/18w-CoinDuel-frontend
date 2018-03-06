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
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var OldPassword: UITextField!
    @IBOutlet weak var UserLabel: UILabel!
    
    @IBAction func submitClicked(_ sender: Any) {
        submitButton.isHidden = true
        OldPassword.text = ""
        OldPassword.placeholder = "new password"
        instructionText.text = "Enter new password"
        confirmPassword.isHidden = false
        confirmButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserLabel.text = UserDefaults.standard.string(forKey:"username")
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = 5
    }
    
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
    @IBAction func onXPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving profile screen")
        }
    }



}
