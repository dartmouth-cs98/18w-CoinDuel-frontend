//
//  LoginViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

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
        signinButton.layer.masksToBounds = true
        signinButton.layer.cornerRadius = 5
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 5
        
        // apply gradient to screen
        self.imageView.applyGradient(colours: [UIColor(red:0.54, green:0.15, blue:0.31, alpha:1.0), UIColor(red:0.65, green:0.18, blue:0.38, alpha:1.0)])
        
        gifView.loadGif(asset: "colors1")
    }
}
