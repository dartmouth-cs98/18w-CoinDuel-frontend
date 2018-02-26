//
//  CoinDetailViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Charts

class CoinDetailViewController: UIViewController {
    @IBOutlet weak var nameHeaderLabel: UILabel!

    var game: Game = Game()
    var coinSymbol: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        nameHeaderLabel.text = coinSymbol

    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("going back")
        }

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
//        self.present(vc, animated: true, completion: nil)
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
