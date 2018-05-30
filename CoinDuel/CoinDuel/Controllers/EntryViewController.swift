//
//  EntryViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 5/29/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Foundation

class EntryViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // sign in
        signinButton.layer.borderWidth = 0.75
        signinButton.layer.masksToBounds = true
        signinButton.layer.cornerRadius = 3
        signinButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.8).cgColor
        
        // sign up
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 3
        signupButton.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:0.8).cgColor
        signupButton.layer.borderWidth = 0.75
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
