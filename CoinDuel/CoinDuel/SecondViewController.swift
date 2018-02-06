//
//  SecondViewController.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/1/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var ViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var serverMessage: String?
        let apiUrl = NSURL(string:"https://coinduel-cs98.herokuapp.com/");
        
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error connecting to server")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            serverMessage = "\(responseString!)"
            DispatchQueue.main.async() {
                self.ViewLabel.text = serverMessage
            }
        }
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
