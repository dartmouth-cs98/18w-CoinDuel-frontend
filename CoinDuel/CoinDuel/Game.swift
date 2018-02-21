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
    var coins:[Coin] = [Coin]()
    var gameStarted:Bool
    
    init() {
        self.id = ""
        self.coins = [Coin]()
        self.gameStarted = false
    }
    
    // Returns total CapCoin allocated so far
    func totalAmount() -> Double {
        var total = 0.0
        for coin in coins {
            total += coin.allocation
        }
        return total
    }
    
    // Returns total CapCoin return so far
    func totalReturn() -> Double {
        var total = 0.0
        for coin in coins {
            total += coin.capCoinReturn
        }
        return total
    }
    
    // Makes request and parses JSON
    // Followed tutorial from https://github.com/SwiftyJSON/SwiftyJSON for all Alamofire requests
    func getCurrentGame(_ gameVC:GameViewController) {
        self.coins = [Coin]()
        let url = Constants.API + "game/"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // Get game ID and whether it has started
                    self.id = json[0]["_id"].stringValue
                    self.gameStarted = json[0]["started"].boolValue

                    // Get all coins (retrieving only the name for now)
                    for coin in json[0]["coins"] {
                        self.coins.append(Coin(coin.1["name"].stringValue, 0.0))
                    }
                    
                    // Update game (get entry if have one)
                    self.updateGame(gameVC)
                case .failure(let error):
                    gameVC.networkError()
                    print(error)
            }
        }
    }
    
    // Retrieves an entry by this user for this game, if it exists
    func updateGame(_ gameVC:GameViewController) {
        let url = Constants.API + "game/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("Json:")
                    print(json)
                    print(".")
                    
                    // Reset coins since we have an entry
                    self.coins = [Coin]()
                
                    // Get all coin names, default CapCoin allocation to 0
                    for coin in json["choices"] {
                        self.coins.append(Coin(coin.1["symbol"].stringValue, coin.1["allocation"].doubleValue))
                    }
                
                    // Get prices
                    self.updateCoinPrices(gameVC)
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
    
    // Submits an entry to the server for this game
    func submitEntry(_ gameVC:GameViewController) {
        var choices = [[String: String]]()
        for coin in self.coins {
            var thisChoice = [String: String]()
            thisChoice["symbol"] = coin.ticker
            thisChoice["allocation"] = String(coin.allocation)
            choices.append(thisChoice)
        }
        
        let json = ["choices": choices]
        
        // Credit for following API technique: https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift

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
    
    func updateCoinPrices(_ gameVC:GameViewController) {
        let url = URL(string: Constants.API + "return/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!)!

        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // Reset coins since we have an entry
                    self.coins = [Coin]()
                    
                    // Get all coin prices, default CapCoin allocation to 0
                    for coin in json["returns"] {
                        let ticker = coin.0
                        print(ticker)
                        let initialPrice = coin.1["initialPrice"].doubleValue
                        let currentPrice = coin.1["currentPrice"].doubleValue
                        let allocation = coin.1["allocation"].doubleValue
                        let capCoin = coin.1["capCoin"].doubleValue
                        let percent = coin.1["percent"].doubleValue
                        self.coins.append(Coin(ticker, initialPrice, currentPrice, allocation, capCoin, percent))
                    }
                    
                    // Reload table view
                    DispatchQueue.main.async() {
                        gameVC.gameTableView.reloadData()
                    }
                case .failure(let error):
                    gameVC.networkError()
                    print(error)
                }
        }
    }
}
