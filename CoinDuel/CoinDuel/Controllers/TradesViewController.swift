//
//  TradesViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 4/26/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class TradesViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("we out")
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
