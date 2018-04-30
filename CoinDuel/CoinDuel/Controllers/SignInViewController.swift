//
//  SignInViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

// Based on code from https://stackoverflow.com/questions/37903124/set-background-gradient-on-button-in-swift

class SignInViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var failedLogin: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var validated = false
    
    // custom grey
    var grey80 = UIColor(red:1, green:1, blue:1, alpha:0.5)

    override func viewDidLoad() {
        print("cook")
    }

    override func viewDidLayoutSubviews(){
        super.viewDidLoad()
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 3
        loginButton.layer.borderColor = grey80.cgColor
        loginButton.layer.borderWidth = 0.75
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Color scheme based on instagram and https://stackoverflow.com/questions/47800574/gradient-over-instagram-svg-of-fontawesome-5
        self.imageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
        
        username.layer.borderWidth = 0
        username.layer.masksToBounds = true
        username.layer.cornerRadius = 3
        username.layer.borderColor = grey80.cgColor
        
        password.layer.borderWidth = 0
        password.layer.masksToBounds = true
        password.layer.cornerRadius = 3
        password.layer.borderColor = grey80.cgColor
        
        // custom placeholders
        // https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        username.attributedPlaceholder = NSAttributedString(string: "Username",
                                                            attributes: [NSAttributedStringKey.foregroundColor: grey80])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: grey80])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        var user_id = ""
        var profileUrl = ""
        var authToken = ""
        
        if let user = username.text, !user.isEmpty, let pass = password.text, !pass.isEmpty {

            let params = ["username": self.username.text!, "password": self.password.text!]
            let apiUrl = URL(string: Constants.API + "signin")

            Alamofire.request(apiUrl!, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in

                if let statusCode = response.response?.statusCode {
                    if (statusCode == 200){
                        do{
                            var json = try JSON(data: response.data!)
                            user_id = json["user"]["_id"].description
                            authToken = json["token"].description
                            profileUrl = json["user"]["profile_url"].description
                            self.validated = true
                        } catch{
                            print("error loading json")
                        }
                    }
                }

                DispatchQueue.main.async() {
                    if (self.validated) {
                        let defaults = UserDefaults.standard
                        defaults.set(user, forKey: "username")
                        defaults.set(user_id, forKey: "id")
                        defaults.set(profileUrl, forKey: "profileImage")
                        defaults.set(authToken, forKey: "authToken")

                        //call main storyboard once succesful sign in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else {
                        self.failedLogin.isHidden = false
                    }
                }
            })

        }
        else{
            let alert = UIAlertController(title: "Invalid Parameters", message: "Enter your username and password!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                print("You've pressed default");
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
    }
}
