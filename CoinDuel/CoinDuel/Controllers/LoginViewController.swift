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
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    //@IBOutlet weak var gifView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {

        signinButton.layer.masksToBounds = true
        signinButton.layer.cornerRadius = 3
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 3
        
        self.imageView.applyGradient(colours: [UIColor(red:0.15, green:0.22, blue:0.27, alpha:1.0), UIColor(red:0.09, green:0.13, blue:0.16, alpha:1.0)])
        // self.imageView.applyGradient(colours: [UIColor.yellow, UIColor.blue, UIColor.red], locations: [0.0, 0.5, 1.0])
        
        //gifView.loadGif(asset: "colors1")
        
    }
    
}
