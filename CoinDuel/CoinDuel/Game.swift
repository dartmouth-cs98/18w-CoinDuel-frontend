//
//  Game.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/16/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

class Game {
    var id:String
    var coins:[String] = [String]()
    var selections:[Bool] = []
    var prices:[Double] = []
    
    init() {
        self.id = ""
        self.coins = [String]()
        self.selections = []
        self.prices = []
    }
    
    func getCurrentGame(_ gameVC:GameViewController) {
        let apiUrl = NSURL(string: Constants.API + "game/");
        
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error connecting to server")
                return
            }
            
            // Parse the JSON response, we only care about the currency_list here
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let response = json as? NSArray {
                    for key in response {
                        if let dict = key as? NSDictionary {
                            if let currencies = dict.value(forKey: "currency_list") as? NSArray {
                                for currency in currencies {
                                    self.coins.append(String(describing: currency))
                                    self.prices.append(0.0)
                                    self.selections.append(false)
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async() {
                gameVC.gameTableView.reloadData()
            }
        }
        
        task.resume()
    }
}
