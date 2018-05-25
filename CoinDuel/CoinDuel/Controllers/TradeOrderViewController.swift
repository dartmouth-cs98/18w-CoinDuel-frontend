//
//  TradeOrderViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 5/24/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

//Source to make popover VC: http://www.seemuapps.com/how-to-make-a-pop-up-view

import UIKit
class TradeOrderViewController: UIViewController {


    @IBOutlet weak var priceLabel: UILabel!
    var coinSymbolLabel: String = ""
    var currentCoinPrice: Double = 0.0
    var allocation: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = CGSize(width: 220,height:90)

//        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.50, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });


    }

    func removeAnimate()
    {
        UIView.animate(withDuration: 0.50, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
                self.dismiss(animated: true, completion: {
                    
                })
            }
        });
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.removeAnimate()
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
