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
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    
    // Color scheme based on instagram and https://stackoverflow.com/questions/47800574/gradient-over-instagram-svg-of-fontawesome-5
    
    override func viewDidLayoutSubviews(){
        self.imageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // The below code for animation logic is based on the two links below
    // https://stackoverflow.com/questions/28127259/update-the-constant-property-of-a-constraint-programmatically-in-swift
    // https://stackoverflow.com/questions/42097082/run-an-animation-with-delay-in-swift
    override func viewDidAppear(_ animated: Bool) {
        let yourDelay = 1
        let yourDuration = 1.0
        self.textView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(yourDelay), execute: { () -> Void in
            self.view.layoutIfNeeded()
            self.textView.isHidden = false
            
            UIView.transition(with: self.label,
                              duration: 0.25,
                              options: [.transitionCrossDissolve],
                              animations: {
                                self.label.text = "CoinDuel Rules!"
            }, completion: nil)
            
            UIView.animate(withDuration: 1, animations: {
                self.sampleConstraint.constant = 20
                self.view.layoutIfNeeded()
            })
            
        })
        
//        self.view.layoutIfNeeded()
//        UIView.animate(withDuration: 1, animations: {
//            self.sampleConstraint.constant = 20
//            self.view.layoutIfNeeded()
//        })
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
