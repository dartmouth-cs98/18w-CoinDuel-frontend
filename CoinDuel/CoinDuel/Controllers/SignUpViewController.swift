//
//  SignUpViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmedPassword: UITextField!
    
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noPasswordLabel: UILabel!
    @IBOutlet weak var noUsernameLabel: UILabel!
    @IBOutlet weak var noEmailLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var profile1: UIButton!
    @IBOutlet weak var profile2: UIButton!
    @IBOutlet weak var profile3: UIButton!
    @IBOutlet weak var profile4: UIButton!
    @IBOutlet weak var profile5: UIButton!
    @IBOutlet weak var profile6: UIButton!
    @IBOutlet weak var profile7: UIButton!
    @IBOutlet weak var profile8: UIButton!
    @IBOutlet weak var profile9: UIButton!
    @IBOutlet weak var profile10: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var buttonPressed = "profile1"
    
    var validated = false
    
    // custom grey
    var grey80 = UIColor(red:1, green:1, blue:1, alpha:0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        
        // signup button views
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 3
        signupButton.layer.borderWidth = 0.75
        signupButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.8).cgColor
        
        // instantiate profile pictiurs
        let profileImages = [profile1, profile2, profile3, profile4, profile5, profile6, profile7, profile8, profile9, profile10]
        var count = 1
        for profile in profileImages {
            profile!.layer.borderWidth = 1
            profile!.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0).cgColor
            profile!.setImage(UIImage(named: "profile" + String(count)), for: .normal)
            count += 1
        }
        
        // highlight default profile pic (profile 1)
        profile1.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // custom placeholders
        // From https://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        username.attributedPlaceholder = NSAttributedString(string: "Username",
                                                            attributes: [NSAttributedStringKey.foregroundColor: self.grey80])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: self.grey80])
        email.attributedPlaceholder = NSAttributedString(string: "Email",
                                                         attributes: [NSAttributedStringKey.foregroundColor: self.grey80])
        confirmedPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: self.grey80])
        
        // add tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // background gradient
        // Color scheme based on instagram and https://stackoverflow.com/questions/47800574/gradient-over-instagram-svg-of-fontawesome-5
        self.imageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func boyButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        resetButtonColors()
        buttonPressed = "profile" + String(button.tag)
        button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
    }
    
    // Below code from https://stackoverflow.com/questions/39392939/how-to-add-a-hyperlink-button-on-ios-swift
    func openUrl(urlStr:String!) {
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    func resetButtonColors() {
        let profileImages = [profile1, profile2, profile3, profile4, profile5, profile6, profile7, profile8, profile9, profile10]
        for profile in profileImages {
            profile!.layer.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0).cgColor
        }
    }
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        // hide all field prompts (e.g. please provide a username)
        self.noPasswordLabel.isHidden = true
        self.noUsernameLabel.isHidden = true
        self.noEmailLabel.isHidden = true
        
        // abondon sign up if errors were detected
        let proceed = self.verifySignUpCredentials()
        if (!proceed) {
            return
        }
        
        // proceed with sign up
        var user_id: String = ""
        var authToken: String = ""
        let apiUrl = URL(string: Constants.API + "signup")
        let profileImage = buttonPressed
        
        // show activity indicator, hide button
        self.signupButton.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        // complete request through alamo fire
        let params = ["username": self.username.text!, "email": self.email.text!, "password": self.password.text!, "profile_url": profileImage]
        Alamofire.request(apiUrl!, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            
            // sign up success!
            if let statusCode = response.response?.statusCode {
                if (statusCode == 200){
                    do{
                        var json = try JSON(data: response.data!)       // parse to json
                        user_id = json["user"]["_id"].description
                        authToken = json["token"].description
                    } catch{
                        print("error loading json")
                    }
                    
                    // set user defaults
                    DispatchQueue.main.async {
                        let defaults = UserDefaults.standard
                        defaults.set(self.username.text!, forKey: "username")
                        defaults.set(user_id, forKey: "id")
                        defaults.set(profileImage, forKey: "profileImage")
                        defaults.set(authToken, forKey: "authToken")
                        self.hideSpinner()
                        
                        // prompt user to check email
                        let alert = UIAlertController(title: "Please verify your email address.", message: "A verification email has been sent to " + self.email.text! + ". You'll be able to login after verifying this address.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { action in self.performSegue(withIdentifier: "fromSignupToSignin", sender: self) })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                
                // identified error sent back
                } else if (statusCode == 422) {
                    do {
                        var json = try JSON(data: response.data!)       // parse to json
                        let alert = UIAlertController(title: json["errTitle"].description, message: json["errBody"].description, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.hideSpinner()
                    } catch {
                        print("error loading json")
                    }
                // unknown error
                } else {
                    let alert = UIAlertController(title: "Oops! Something went wrong.", message: "We're sorry about this. Please restart the app and try again.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    self.hideSpinner()
                }
            }
        })
    }

    /*
     * Ensure all information entered by the user is complete and valid.
     * @return Bool, indicating if app can proceed with sign up
     */
    func verifySignUpCredentials() -> Bool {
        // check for incomplete fields
        var incompletes = false
        var errTitle = "Oops! "
        var errBody = ""
        
        // prompt user for username if empty
        if (self.username.text == "") {
            incompletes = true
            errTitle += "You forgot to enter a username."
            errBody = "Please enter a username and try again."
            self.noUsernameLabel.isHidden = false
            
        // prompt user for email if empty
        } else if (self.email.text == "") {
            incompletes = true
            errTitle += "You forgot to enter your email address."
            errBody = "Please enter your email and try again."
            self.noEmailLabel.isHidden = false
            
        // prompt user for password if both empty
        } else if (self.password.text == "" && self.confirmedPassword.text == "") {
            incompletes = true
            errTitle += "You forgot to enter a password."
            errBody = "Please enter a password and try again."
            self.noPasswordLabel.isHidden = false
            
        // prompt user for double password if one empty
        } else if (self.password.text == "" || self.confirmedPassword.text == "") {
            incompletes = true
            errTitle += "You must enter your password twice."
            errBody = "Please enter a password in both password fields and try again."
            self.noPasswordLabel.isHidden = false
            
        // ensure passwords match
        } else if (self.password.text != self.confirmedPassword.text){
            let alert = UIAlertController(title: "Oops! Passwords do not match.", message: "Please make sure your passwords match and try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            // clear password fields
            self.password.text = ""
            self.confirmedPassword.text = ""
            return false
        }
        
        // display error if detected
        if (incompletes == true) {
            let alert = UIAlertController(title: errTitle, message: errBody, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        // no errors!
        return true
    }
    
    func hideSpinner() ->  Void{
        activityIndicator.isHidden = true
        signupButton.isHidden = false
        activityIndicator.stopAnimating()
    }
}
