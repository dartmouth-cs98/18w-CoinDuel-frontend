//
//  ProfileViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 4/30/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!

    var user = User(username: UserDefaults.standard.string(forKey: "username"), coinBalance: 0.0, rank: 0, profilePicture: "profile")
    

    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLogOutPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // reset all user defaults except username
        dictionary.keys.forEach { key in
            if (key != "username") {
                defaults.removeObject(forKey: key)
            }
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(gameVC, animated: true, completion: nil)

        // From https://stackoverflow.com/questions/29374235/facebook-sdk-4-0-ios-swift-log-a-user-out-programmatically
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function

    }
    @IBAction func onXPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("byebye")
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
