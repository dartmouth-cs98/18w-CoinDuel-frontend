//
//  LoginViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        signinButton.layer.masksToBounds = true
        signinButton.layer.cornerRadius = 5
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 5
    }
}
