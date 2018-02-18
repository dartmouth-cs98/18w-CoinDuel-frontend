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
    
    var validated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        failedLogin.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
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
                                if let name = dict.value(forKey: "username") as? String, let pw = dict.value(forKey: "password") as? String {
                                    if user == name, pass == pw {
                                        self.validated = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async() {
                    if (self.validated) {
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
