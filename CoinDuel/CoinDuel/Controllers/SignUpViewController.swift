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
        
        // reset dynamic messages
        self.noPasswordLabel.text = "enter and confirm a password"
        self.noEmailLabel.text = "enter your email address"
        
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
                        
                    // unable to parse json
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
                        
                        // prompt user to check email
                        let alert = UIAlertController(title: "Please verify your email address.", message: "A verification email has been sent to " + self.email.text! + ". You'll be able to login after verifying this address.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { action in self.performSegue(withIdentifier: "fromSignupToSignin", sender: self) })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.hideSpinner()
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
                        
                    // unable to parse json
                    } catch {
                        print("error loading json")
                        self.hideSpinner()
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
        // prompt user for username if empty
        if (self.username.text == "") {
            self.noUsernameLabel.isHidden = false
            return false
            
        // prompt user for email if empty
        } else if (self.email.text == "") {
            self.noEmailLabel.isHidden = false
            return false
        
        // prompt user if email address is invalid
        } else if (isValidEmail(email : self.email.text!) == false) {
            self.noEmailLabel.text = "invalid email"
            self.noEmailLabel.isHidden = false
            return false
            
        // prompt user for password if empty
        } else if (self.password.text == "") {
            self.noPasswordLabel.isHidden = false
            return false
            
        // prompt user if password is too short
        } else if ((self.password.text?.count)! < 6) {
            self.noPasswordLabel.text = "passwords must be at least 6 characters"
            self.noPasswordLabel.isHidden = false
            return false
            
        // prompt user to confirm passwords
        } else if (self.confirmedPassword.text == "") {
            self.noPasswordLabel.text = "confirm your password"
            self.noPasswordLabel.isHidden = false
            return false
            
        // prompt user that passwords do not match
        } else if (self.password.text != self.confirmedPassword.text){
            self.noPasswordLabel.text = "passwords do not match"
            self.noPasswordLabel.isHidden = false
            return false
        }

        // no errors!
        return true
    }
    
    /*
     * Validate an email address based on regular expressions.
     * @return Bool, indicating if the email is valid
     * ADAPTED FROM: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
     */
    func isValidEmail(email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let validator = NSPredicate(format : "SELF MATCHES %@", regex)
        return validator.evaluate(with : email)
    }

    /*
     * Pass username and password into login view controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SignInViewController {
            let controller = segue.destination as? SignInViewController
            controller?.usernamePreload = self.username.text
            controller?.passwordPreload = self.password.text
        }
    }
    
    func hideSpinner() ->  Void{
        self.activityIndicator.isHidden = true
        self.signupButton.isHidden = false
        self.activityIndicator.stopAnimating()
    }
}
