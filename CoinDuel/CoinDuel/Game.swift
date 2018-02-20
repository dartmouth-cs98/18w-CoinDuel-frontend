//
//  Game.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/16/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Game {
    var id:String
    var coins:[String] = [String]()
    var amounts:[Double] = []
    var gameStarted:Bool
    
    init() {
        self.id = ""
        self.coins = [String]()
        self.amounts = []
        self.gameStarted = false
    }
    
    // Returns total CapCoin allocated so far
    func totalAmount() -> Double {
        var total = 0.0
        for amount in amounts {
            total += amount
        }
        return total
    }
    
    // Makes request and parses JSON
    // Followed tutorial from https://github.com/SwiftyJSON/SwiftyJSON for all Alamofire requests
    func getCurrentGame(_ gameVC:GameViewController) {
        let url = Constants.API + "game/"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // Get game ID
                    self.id = json[0]["_id"].stringValue

                    // Get all coin names, default CapCoin allocation to 0
                    for coin in json[0]["coins"] {
                        self.coins.append(coin.1["name"].stringValue)
                        self.amounts.append(0.0)
                    }
                    
                    // Update game (get entry if have one)
                    self.updateGame(gameVC)
                case .failure(let error):
                    gameVC.networkError()
                    print(error)
            }
        }
    }
    
    func updateGame(_ gameVC:GameViewController) {
        let url = Constants.API + "game/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("Json:")
                    print(json)
                    print(".")
                    
                    // Reset coins and amounts since we have an entry
                    self.coins = [String]()
                    self.amounts = []
                
                    // Get all coin names, default CapCoin allocation to 0
                    for coin in json["choices"] {
                        self.coins.append(coin.1["symbol"].stringValue)
                        self.amounts.append(coin.1["allocation"].doubleValue)
                    }
                
                    // Reload tableview
                    DispatchQueue.main.async() {
                        gameVC.gameTableView.reloadData()
                    }
                case .failure(let error):
                    if String(describing: error) == Constants.MissingEntryError {
                        // All OK, just no entry yet. Reload tableview
                        DispatchQueue.main.async() {
                            gameVC.gameTableView.reloadData()
                        }
                    } else {
                        gameVC.networkError()
                        print(error)
                    }
            }
        }
    }
    
    func submitEntry(_ gameVC:GameViewController) {
        // Submits the entry to the server
        var choices = [[String: String]]()
        var x = 0
        for choice in self.coins {
            var thisChoice = [String: String]()
            thisChoice["symbol"] = String(describing: choice)
            thisChoice["allocation"] = String(self.amounts[x])
            choices.append(thisChoice)
            x += 1
        }
        
        var json = ["choices": choices]
        
        // Credit for following API technique: https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
//        let json: [String: [Array<String>]] = ["choices": choices]

        if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
            let url = URL(string: Constants.API + "game/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!)!

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
}
