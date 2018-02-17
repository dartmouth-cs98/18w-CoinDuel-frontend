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
    
    func submitEntry(_ gameVC:GameViewController) {
        // Submits the entry to the server

        var choices = [Array<String>]()
        var x = 0
        for choice in self.coins {
            if self.amounts[x] > 0 {
                let thisChoice = [String(choice), String(self.amounts[x])]
                choices.append(thisChoice)
            }
            x += 1
        }
        
        // Credit for following API technique: https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
        let json: [String: [Array<String>]] = ["choices": choices]

        if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
            let url = URL(string: Constants.API + "game/" + Constants.TEMP_USER_ID + "/" + self.id)!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            print(request)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                // Error checking
                guard error == nil else {
                    gameVC.networkError()
                    return
                }
                
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    print(jsonResponse)
                    DispatchQueue.main.async() {
                        self.updateGame(gameVC)
                    }
                }
            }
            
            task.resume()
        } else {
            print("Failed conversion to JSON")
        }
    }
    
    func getCurrentGameApi(_ gameVC:GameViewController, _ api:String) {
        let apiUrl = NSURL(string: api)
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            // Error checking
            guard error == nil else {
                gameVC.networkError()
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
        let apiUrl = NSURL(string: api)
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Error checking
            guard error == nil else {
                gameVC.networkError()
                return
            }
            
            // Parse the JSON response, we only care about the choices here
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let dict = json as? NSDictionary {
                    if let choices = dict.value(forKey: "choices") as? NSArray {
                        for choice in choices {
                            if let selection = choice as? NSArray {
                                let coin = selection[0] as! String
                                let amount = Double(selection[1] as! String)
                                self.coins.append(coin)
                                self.amounts.append(amount!)
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
