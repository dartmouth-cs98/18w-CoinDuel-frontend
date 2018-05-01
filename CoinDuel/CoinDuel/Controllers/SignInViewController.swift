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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // preloaded username / password from signup
    var usernamePreload: String? = nil
    var passwordPreload: String? = nil
    
    var validated = false
    
    // custom grey
    var grey80 = UIColor(red:1, green:1, blue:1, alpha:0.5)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        self.loginButton.isHidden = false
        
        // custom placeholders
        // https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        username.attributedPlaceholder = NSAttributedString(string: "Username",
                                                            attributes: [NSAttributedStringKey.foregroundColor: grey80])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: grey80])
        
        // set preloaded username / password if any
        if (usernamePreload != nil) {
            self.username.text = usernamePreload
        }
        if (passwordPreload != nil) {
            self.password.text = passwordPreload
        }
    }

    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        self.failedLogin.isHidden = true
        var user_id = ""
        var profileUrl = ""
        var authToken = ""
        
        // prompt and user for all fields and bail if need be
        if (self.username.text == "" || self.password.text == "") {
            self.failedLogin.isHidden = false
            return
        }
        
        // show activity indicator, hide button
        self.loginButton.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        // request login through alamo fire
        let params = ["username": self.username.text!, "password": self.password.text!]
        let apiUrl = URL(string: Constants.API + "signin")
        Alamofire.request(apiUrl!, method: HTTPMethod.post, parameters: params)
            .responseJSON { response in
            
                // parse response
                if let statusCode = response.response?.statusCode {
                    if (statusCode == 200){
                        do{
                            var json = try JSON(data: response.data!)   // parse json
                            user_id = json["user"]["_id"].description
                            authToken = json["token"].description
                            profileUrl = json["user"]["profile_url"].description
                            self.validated = true
                            
                        // unable to parse json
                        } catch{
                            print("error loading json")
                            self.hideSpinner()
                        }
                    }
                }
            
                // login user!
                DispatchQueue.main.async() {
                    if (self.validated) {
                        let defaults = UserDefaults.standard
                        defaults.set(self.username.text, forKey: "username")
                        defaults.set(user_id, forKey: "id")
                        defaults.set(profileUrl, forKey: "profileImage")
                        defaults.set(authToken, forKey: "authToken")

                        // call main storyboard once succesful sign in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            .responseString { response in
                
                // bail if user has been validated (aka already logged in)
                if (self.validated) {
                    return
                }
                
                // init alert message fields
                var errTitle = ""
                var errBody = ""
                
                // username does not exist in database
                if (response.result.value?.range(of:"error-username") != nil) {
                    errTitle = "Hmm, we can't find a user with this username."
                    errBody = "Please check your username and try again."
                    
                // user exists, but password is incorrect
                } else if (response.result.value?.range(of:"error-password") != nil) {
                    errTitle = "Hmm, it looks like your password is incorrect."
                    errBody = "Please re-enter your password and try again."
                    self.password.text = ""
                
                // user has not verified his email
                } else if(response.result.value?.range(of:"error-verify") != nil) {
                    errTitle = "Hmm, it looks like you haven't verified your email address."
                    errBody = "Please check your inbox for a verification email from us."
                    
                // unknown error
                } else {
                    errTitle = "Oops! Our server seems to running into some trouble."
                    errBody = "Please wait a moment and try again."
                }
                
                // display error in alert popup
                let alert = UIAlertController(title: errTitle, message: errBody, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                self.hideSpinner()
            }
    }
    
    func hideSpinner() ->  Void{
        self.activityIndicator.isHidden = true
        self.loginButton.isHidden = false
        self.activityIndicator.stopAnimating()
    }
}
