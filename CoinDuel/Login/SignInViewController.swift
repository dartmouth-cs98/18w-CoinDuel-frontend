//
//  SignInViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var failedLogin: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var validated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        var user_id = ""
        
        if let user = username.text, !user.isEmpty, let pass = password.text, !pass.isEmpty {
            let apiUrl = NSURL(string:Constants.API + "user");
            let request = NSMutableURLRequest(url:apiUrl! as URL);
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print("error connecting to server")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    if let response = json as? NSArray {
                        for key in response {
                            if let dict = key as? NSDictionary {
                                if let name = dict.value(forKey: "username") as? String, let pw = dict.value(forKey: "password") as? String, let id = dict.value(forKey: "id") as? String {
                                    if user == name, pass == pw {
                                        self.validated = true
                                        user_id = id
                                    }
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async() {
                    if (self.validated) {
                        let defaults = UserDefaults.standard
                        defaults.set(user, forKey: "username")
                        defaults.set(user_id, forKey: "id")
                        defaults.set("girl", forKey: "profileImage")
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    else {
                        self.failedLogin.isHidden = false
                    }
                }
            }
            
            task.resume()
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
