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
    
    @IBOutlet weak var boyButton: UIButton!
    @IBOutlet weak var girlButton: UIButton!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var catButton: UIButton!
    
    
    @IBOutlet weak var profile5: UIButton!
    @IBOutlet weak var profile6: UIButton!
    @IBOutlet weak var profile7: UIButton!
    @IBOutlet weak var profile8: UIButton!
    
    
    var buttonPressed = "boy"
    
    var validated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        boyButton.layer.borderWidth = 1
        boyButton.layer.borderColor = UIColor.black.cgColor
        boyButton.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
        girlButton.layer.borderWidth = 1
        girlButton.layer.borderColor = UIColor.black.cgColor
        dogButton.layer.borderWidth = 1
        dogButton.layer.borderColor = UIColor.black.cgColor
        catButton.layer.borderWidth = 1
        catButton.layer.borderColor = UIColor.black.cgColor
        
        profile5.layer.borderWidth = 1
        profile5.layer.borderColor = UIColor.black.cgColor
        
        boyButton.setImage(UIImage(named: "boy"), for: .normal)
        girlButton.setImage(UIImage(named: "girl"), for: .normal)
        dogButton.setImage(UIImage(named: "dog"), for: .normal)
        catButton.setImage(UIImage(named: "cat"), for: .normal)
        profile5.setimage(UIImage(named:))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func boyButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        
        switch button.tag {
            case 1:
                resetButtonColors()
                buttonPressed = "boy"
                button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
            case 2:
                resetButtonColors()
                buttonPressed = "dog"
                button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
            case 3:
                resetButtonColors()
                buttonPressed = "cat"
                button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
            case 4:
                resetButtonColors()
                buttonPressed = "girl"
                button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
            case 4:
                resetButtonColors()
                buttonPressed = "profile5"
                button.layer.backgroundColor = UIColor(red: (220/255.0), green: (220/255.0), blue: (220/255.0), alpha: 1.0).cgColor
            default:
                print("Unknown language")
                return
        }
    }
    
    func resetButtonColors() {
        boyButton.layer.backgroundColor = UIColor.white.cgColor
        girlButton.layer.backgroundColor = UIColor.white.cgColor
        dogButton.layer.backgroundColor = UIColor.white.cgColor
        catButton.layer.backgroundColor = UIColor.white.cgColor
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
