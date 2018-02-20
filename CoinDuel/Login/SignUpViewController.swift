//
//  SignUpViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/18/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Alamofire

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

    var validated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

            let params = ["username": username.text, "email": email.text, "password": password.text]
            let headers: HTTPHeaders = [
                "Accept": "application/json"
            ]

            print(params, headers)
            let apiUrl = URL(string: Constants.API + "signup")

            let parameters = ["username": username.text, "email": email.text, "password": password.text]

            // Both calls are equivalent
            Alamofire.request(apiUrl!, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                case .failure(let error):
                    print(error)
                }
            })

//            var request = URLRequest(url:apiUrl! as URL);
//
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else{
//                print("error making body"); return
//            }
//
//            request.httpBody = body
//
//            let session = URLSession.shared
//            session.dataTask(with: request, completionHandler: { (data, response, error) in
//                if let httpResponse = response as? HTTPURLResponse {
//                    if (httpResponse.statusCode == 200){
//                        self.validated = true
//                        DispatchQueue.main.async {
//                            self.activityIndicator.isHidden = true
//                            self.activityIndicator.stopAnimating()
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
//                            self.present(vc, animated: true, completion: nil)
//                        }
//                    }
//                }
//
//                if let error = error {
//                    print(error)
//                }
//            }).resume()
        }

    }
}
