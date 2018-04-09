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
    @IBOutlet weak var profile11: UIButton!
    @IBOutlet weak var profile12: UIButton!
    
    var buttonPressed = "profile1"
    
    var validated = false

    //@IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var isSlideMenuHidden = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // initialize constant with 0
        sideMenuConstraint.constant = -800
        
        self.activityIndicator.isHidden = true
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let profileImages = [profile1, profile2, profile3, profile4, profile5, profile6, profile7, profile8, profile9, profile10, profile11, profile12]
        
        var count = 1
        for profile in profileImages {
            profile!.layer.borderWidth = 1
            profile!.layer.borderColor = UIColor.black.cgColor
            profile!.setImage(UIImage(named: "profile" + String(count)), for: .normal)
            count = count + 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Below code based on tutorial found at this link: https://www.youtube.com/watch?v=mmSEidHEGL8
    
    @IBAction func organizeBtnPressed(_ sender: UIButton) {
        
        if isSlideMenuHidden {
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })

        } else {
            sideMenuConstraint.constant = -800
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isSlideMenuHidden = !isSlideMenuHidden
    }
    
    // Based on this link: https://stackoverflow.com/questions/39392939/how-to-add-a-hyperlink-button-on-ios-swift
    
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func linkedButton(_ sender: Any) {
        openUrl(urlStr: "http://www.dartmouth.edu/~dpc/")
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        openUrl(urlStr: "https://twitter.com/")
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        openUrl(urlStr: "https://www.facebook.com/")
    }
    
    @IBAction func instaButton(_ sender: Any) {
        openUrl(urlStr: "https://www.instagram.com/p/BhUeeTeBrob/?tagged=cryptocurrency")
    }
    
    @IBAction func boyButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        
        resetButtonColors()
        buttonPressed = "profile" + String(button.tag)
        button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
    }
    
    
    func resetButtonColors() {
        let profileImages = [profile1, profile2, profile3, profile4, profile5, profile6, profile7, profile8, profile9, profile10, profile11, profile12]
        for profile in profileImages {
            profile!.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func onSignUpPressed(_ sender: Any) {

//        display error messages if fields are empty
        if (username.text == "" || email.text == "" || password.text == "" || confirmedPassword.text == ""){
            let alert = UIAlertController(title: "Invalid Parameters", message: "Please fill in all appropriate fields!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Go Back", style: .default) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if (password.text != confirmedPassword.text){
            let alert = UIAlertController(title: "Incorrect Passwords", message: "Please make sure your passwords match!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Go Back", style: .default) { (action:UIAlertAction) in
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
//        if all field are filled sign up the user
        else{
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            var user_id: String = ""


            let apiUrl = URL(string: Constants.API + "signup")

            let profileImage = buttonPressed
            let params = ["username": self.username.text!, "email": self.email.text!, "password": self.password.text!, "profile_url": profileImage]
            Alamofire.request(apiUrl!, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in


                if let statusCode = response.response?.statusCode {
                    if (statusCode == 200){
                        do{
                            var jsonArray = try JSON(data: response.data!)
                            user_id = jsonArray["_id"].description
                        } catch{
                            print("error loading json")
                        }
                        DispatchQueue.main.async {
                            let defaults = UserDefaults.standard
                            defaults.set(self.username.text!, forKey: "username")
                            defaults.set(user_id, forKey: "id")
                            defaults.set(profileImage, forKey: "profileImage")
                            self.hideSpinner()
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
                            self.present(vc, animated: true, completion: nil)
                        }
                    } else if(statusCode == 422) {
                        let alert = UIAlertController(title: "Please Try Again!", message: "That username has been taken!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.hideSpinner()
                    } else{
                        let alert = UIAlertController(title: "Error!", message: "Something went wrong.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.hideSpinner()
                    }

                }
            })
        }

    }
    func hideSpinner() ->  Void{
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}
