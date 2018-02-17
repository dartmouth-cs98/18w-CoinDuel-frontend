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
    var amounts:[Double] = []
    
    init() {
        self.id = ""
        self.coins = [String]()
        self.amounts = []
    }
    
    func totalAmount() -> Double {
        var total = 0.0
        for amount in amounts {
            total += amount
        }
        return total
    }
    
    func updateGame(_ gameVC:GameViewController) {
        self.coins = [String]()
        self.amounts = []
        self.getEntryApi(gameVC, Constants.API + "game/" + Constants.TEMP_USER_ID + "/" + self.id)
    }
    
    func retrieveCurrentGame(_ gameVC:GameViewController) {
        self.getCurrentGameApi(gameVC, Constants.API + "game/")
    }
    
    func submitEntry() -> Bool {
        // Submits the entry to the server
        
        return true
    }
    
    func getCurrentGameApi(_ gameVC:GameViewController, _ api:String) {
        let apiUrl = NSURL(string: api)
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
                                    self.amounts.append(0.0)
                                }
                            }
                            if let gameId = dict.value(forKey: "_id") as? String {
                                print("Setting id")
                                print(gameId)
                                self.id = gameId
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
    
    func getEntryApi(_ gameVC:GameViewController, _ api:String) {
        print("Getting entry api")
        let apiUrl = NSURL(string: api)
        print(apiUrl)
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("About to retrieve data")
            
            if error != nil {
                print("error connecting to server")
                return
            }
            
            print("About to read JSON")
            
            // Parse the JSON response, we only care about the choices here
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Json:")
                print(json)
//                if let response = json as? NSArray {
//                    for key in response {
//                        print("Key: ")
//                        print(key)
                        if let dict = json as? NSDictionary {
                            print("Dict: ")
                            print(dict)
                            if let choices = dict.value(forKey: "choices") as? NSArray {
                                print("Choices: ")
                                print(choices)
                                for choice in choices {
                                    if let selection = choice as? NSArray {
                                        let coin = selection[0] as! String
                                        let amount = 0.0 // selection[1] as! String
                                        
                                        self.coins.append(coin)
                                        self.amounts.append(amount)
                                    }
                                }
//                            }
                        }
//                    }
                }
            }
            
            DispatchQueue.main.async() {
                gameVC.gameTableView.reloadData()
            }
        }
        
        task.resume()
    }
}
