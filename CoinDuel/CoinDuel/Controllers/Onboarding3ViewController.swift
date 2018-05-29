//
//  Onboarding3ViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 5/28/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class Onboarding3ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sampleConstraint: NSLayoutConstraint!
    
    // Color scheme based on instagram and https://stackoverflow.com/questions/47800574/gradient-over-instagram-svg-of-fontawesome-5
    
    override func viewDidLayoutSubviews(){
        self.imageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // https://stackoverflow.com/questions/28127259/update-the-constant-property-of-a-constraint-programmatically-in-swift
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: {
            self.sampleConstraint.constant = 20
            self.view.layoutIfNeeded()
        })
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
