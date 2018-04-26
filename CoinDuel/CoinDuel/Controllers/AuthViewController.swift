//
//  AuthViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 4/26/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit

class AuthViewController: UIViewController {
    
    var dict : [String : AnyObject]!

    // fb auth
    var fbLoginButton = LoginButton(readPermissions: [ .publicProfile ])
    
    override func viewDidAppear(_ animated: Bool) {
        
        //  From https://www.simplifiedios.net/facebook-login-swift-3-tutorial/
        //  FacebookLogin
        //  Created by Belal Khan on 09/08/17.
        //  Copyright © 2017 Belal Khan. All rights reserved.
        
        //center button
        self.fbLoginButton.center = view.center
        
        //adding it to view
        view.addSubview(fbLoginButton)
        
        //if the user is already logged in
        if let accessToken = FBSDKAccessToken.current(){
            segueWithFBAuth()
        }
        
    }
    
    //  Below 2 functions from https://www.simplifiedios.net/facebook-login-swift-3-tutorial/
    //  FacebookLogin
    //  Created by Belal Khan on 09/08/17.
    //  Copyright © 2017 Belal Khan. All rights reserved.
    
    //when login button clicked
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.segueWithFBAuth()
                
                // async segue
                DispatchQueue.main.async() {
                    //call main storyboard once succesful sign in
                    print("segue to main")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                }
                
                // segue to main storyboard
                // Based on https://stackoverflow.com/questions/36238925/segue-wont-trigger-after-facebook-login-with-swift
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    //function is fetching the user data
    func segueWithFBAuth(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    
                    //set deaults
                    let defaults = UserDefaults.standard
                    defaults.set(self.dict["name"], forKey: "username")
                    defaults.set("profile1", forKey: "profileImage")
                    
                    //needs to signup / login
                    //                    defaults.set(self.dict["id"], forKey: "id")
                    //                    defaults.set(authToken, forKey: "authToken")
                    
                    //segue to main storyboard
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print(error)
                }
            })
            
            // unable to generate access taken
        } else {
            self.fbLoginButton.alpha = 0
            
            // alert user of issue
            // https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
            let alert = UIAlertController(title: "Unable to login with Facebook.", message: "Facebook was unable log you in from this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
