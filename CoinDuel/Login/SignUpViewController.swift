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
    
    @IBOutlet weak var profile9: UIButton!
    @IBOutlet weak var profile10: UIButton!
    @IBOutlet weak var profile11: UIButton!
    @IBOutlet weak var profile12: UIButton!
    
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
        
        profile6.layer.borderWidth = 1
        profile6.layer.borderColor = UIColor.black.cgColor
        
        profile7.layer.borderWidth = 1
        profile7.layer.borderColor = UIColor.black.cgColor
        
        profile8.layer.borderWidth = 1
        profile8.layer.borderColor = UIColor.black.cgColor
        
        profile9.layer.borderWidth = 1
        profile9.layer.borderColor = UIColor.black.cgColor
        
        profile10.layer.borderWidth = 1
        profile10.layer.borderColor = UIColor.black.cgColor
        
        profile11.layer.borderWidth = 1
        profile11.layer.borderColor = UIColor.black.cgColor
        
        profile12.layer.borderWidth = 1
        profile12.layer.borderColor = UIColor.black.cgColor
        
        boyButton.setImage(UIImage(named: "profile1"), for: .normal)
        girlButton.setImage(UIImage(named: "profile4"), for: .normal)
        dogButton.setImage(UIImage(named: "profile2"), for: .normal)
        catButton.setImage(UIImage(named: "profile3"), for: .normal)
        profile5.setImage(UIImage(named: "profile5"), for: .normal)
        profile6.setImage(UIImage(named: "profile6"), for: .normal)
        profile7.setImage(UIImage(named: "profile7"), for: .normal)
        profile8.setImage(UIImage(named: "profile8"), for: .normal)
        profile9.setImage(UIImage(named: "profile9"), for: .normal)
        profile10.setImage(UIImage(named: "profile10"), for: .normal)
        profile11.setImage(UIImage(named: "profile11"), for: .normal)
        profile12.setImage(UIImage(named: "profile12"), for: .normal)
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
    
    func resetButtonColors() {
        boyButton.layer.backgroundColor = UIColor.white.cgColor
        girlButton.layer.backgroundColor = UIColor.white.cgColor
        dogButton.layer.backgroundColor = UIColor.white.cgColor
        catButton.layer.backgroundColor = UIColor.white.cgColor
        profile5.layer.backgroundColor = UIColor.white.cgColor
        profile6.layer.backgroundColor = UIColor.white.cgColor
        profile7.layer.backgroundColor = UIColor.white.cgColor
        profile8.layer.backgroundColor = UIColor.white.cgColor
        profile9.layer.backgroundColor = UIColor.white.cgColor
        profile10.layer.backgroundColor = UIColor.white.cgColor
        profile11.layer.backgroundColor = UIColor.white.cgColor
        profile12.layer.backgroundColor = UIColor.white.cgColor
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
