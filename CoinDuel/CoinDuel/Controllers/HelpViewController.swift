//
//  HelpViewController.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 4/12/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Below code from https://stackoverflow.com/questions/39392939/how-to-add-a-hyperlink-button-on-ios-swift
    
    func openUrl(urlStr:String!) {
        
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func instaButton(_ sender: Any) {
        openUrl(urlStr: "https://www.instagram.com/bitcoinbillionaires_/")
    }
    
    @IBAction func fbookButton(_ sender: Any) {
        openUrl(urlStr: "https://www.facebook.com/cryptocurrencyupdates/")
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        openUrl(urlStr: "https://twitter.com/bitcoinprivate")
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
