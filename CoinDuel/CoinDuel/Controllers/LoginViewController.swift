//
//  LoginViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

// Based on code from https://stackoverflow.com/questions/37903124/set-background-gradient-on-button-in-swift

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var gifView: UIImageView!
    override func viewDidLoad() {
        
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
        
        
        // apply gradient to screen
        // Color scheme based on instagram and https://stackoverflow.com/questions/47800574/gradient-over-instagram-svg-of-fontawesome-5
        // self.imageView.applyGradient(colours: [UIColor(red:0.44, green:0.09, blue:0.92, alpha:1.0), UIColor(red:0.92, green:0.38, blue:0.38, alpha:1.0)])
        self.imageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
        //self.imageView.applyGradient(colours: [UIColor(red:0.99, green:0.96, blue:0.59, alpha:1.0), UIColor(red:0.99, green:0.96, blue:0.59, alpha:1.0), UIColor(red:0.99, green:0.35, blue:0.29, alpha:1.0), UIColor(red:0.84, green:0.14, blue:0.62, alpha:1.0),UIColor(red:0.16, green:0.35, blue:0.92, alpha:1.0)], locations: [0.0, 0.05, 0.45, 0.6, 0.9])
        
        gifView.loadGif(asset: "colors1")
    }
    
    @IBAction func back1(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving game VC")
        }
    }
    
    
}
