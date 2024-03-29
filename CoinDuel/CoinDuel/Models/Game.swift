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
    var isActive:Bool
    var hasFinished:Bool
    var finishedAndProcessed:Bool
    var numberOfUsers: Int
    var startDate:String
    var finishDate:String
    var rawStartDate:String
    var coinBalance:Double
    var unusedCoinBalance:Double
    
    init() {
        self.id = ""
        self.coins = [Coin]()
        self.isActive = false
        self.hasFinished = false
        self.finishedAndProcessed = false
        self.startDate = ""
        self.finishDate = ""
        self.rawStartDate = ""
        self.coinBalance = 0.0
        self.unusedCoinBalance = 0.0
        self.numberOfUsers = 0
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
    
    // Returns total % return so far
    func totalPercentageReturn() -> Double {
        return (self.totalReturn() - 10.0) * 100.0
    }
    
    // Makes request and parses JSON
    // Followed tutorial from https://github.com/SwiftyJSON/SwiftyJSON for all Alamofire requests
    func getCurrentGame(completion: @escaping (_ success: Bool) -> Void) {
        let url = Constants.API + "game/"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // Get game ID and whether it has started
                    self.id = json[0]["_id"].stringValue
                    self.isActive = json[0]["is_active"].boolValue
                    self.hasFinished = json[0]["game_finished"].boolValue
                    self.finishedAndProcessed = json[0]["has_ended"].boolValue
                    self.numberOfUsers = json[0]["users"].intValue
                    // Get the date (https://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    guard let startDate = dateFormatter.date(from: json[0]["start_date"].stringValue), let finishDate = dateFormatter.date(from: json[0]["finish_date"].stringValue) else {
                        completion(false)
                        return
                    }
                    self.rawStartDate = startDate.description
                    dateFormatter.dateFormat = "EEE, h:mm a z"
                    dateFormatter.timeZone = TimeZone.current
                    self.startDate = dateFormatter.string(from: startDate)
                    self.finishDate = dateFormatter.string(from: finishDate)
                    
                    self.coins = [Coin]()

                    // Get all coins (retrieving only the name for now)
                    for coin in json[0]["coins"] {
                        
                        self.coins.append(Coin(coin.1["name"].stringValue, 0.0, coin.1["startPrice"].doubleValue))
                    }
                    
                    self.coins.sort(by: {$0.ticker < $1.ticker})
                    self.coins.sort(by: {$0.allocation > $1.allocation})

                    
                    // Update game (get entry if have one)
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
            }
        }
    }
    
    // Retrieves an entry by this user for this game, if it exists
    func getEntry(completion: @escaping (_ entryStatus: String) -> Void) {
        let url = Constants.API + "game/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!
        print(url)
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                                                            
                    // Reset coins since we have an entry
                    self.coins = [Coin]()
                
                    // Get all coin names, default CapCoin allocation to 0
                    for coin in json["currentChoices"] {
                        self.coins.append(Coin(coin.1["symbol"].stringValue, coin.1["allocation"].doubleValue, coin.1["startPrice"].doubleValue))
                    }
                    
                    self.coins.sort(by: {$0.ticker < $1.ticker})
                    self.coins.sort(by: {$0.allocation > $1.allocation})
                    
                    self.coinBalance = json["coin_balance"].doubleValue
                    self.unusedCoinBalance = json["unallocated_capcoin"].doubleValue
                
                    completion("entry")
                case .failure(let error):
                    if String(describing: error) == Constants.MissingEntryError {
                        // All OK, just no entry yet. Reload tableview
                        completion("none")
                    } else {
                        print(error)
                        completion("error")
                    }
            }
        }
    }
    
    // Submits an entry to the server for this game
    func submitEntry(completion: @escaping (_ success: Bool) -> Void) {
        var choices = [[String: String]]()
        for coin in self.coins {
            var thisChoice = [String: String]()
            thisChoice["symbol"] = coin.ticker
            thisChoice["allocation"] = String(coin.allocation)
            choices.append(thisChoice)
        }
        
        print("Choices")
        print(choices)
        
        let json = ["choices": choices]

        let url = URL(string: Constants.API + "game/" + self.id + "/" + UserDefaults.standard.string(forKey:"id")!)!

        Alamofire.request(url, method: .post, parameters: json, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                // check for insufficient funds
                if (json["error"].exists() && json["error"] == "insufficient funds") {
                    completion(false)
                    print("heheehehehe")
                    print (json["error"])
                    return
                }
                
                // Get all coin names, default CapCoin allocation to 0
                self.coins = [Coin]()
                for coin in json["currentChoices"] {
                    self.coins.append(Coin(coin.1["symbol"].stringValue, coin.1["allocation"].doubleValue, coin.1["startPrice"].doubleValue))
                }
                completion(true)

            case .failure(let error):
                if String(describing: error) == Constants.MissingEntryError {
                    // All OK, just no entry yet. Reload tableview
                } else {
                    print(error)
                }
                completion(false)
            }
        }
    }

    func updateCoinPricesAndReturns(completion: @escaping (_ success: Bool) -> Void) {
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
//                        print(ticker)
                        let initialPrice = coin.1["initialPrice"].doubleValue
                        let currentPrice = coin.1["currentPrice"].doubleValue
                        let allocation = coin.1["allocation"].doubleValue
                        let capCoin = coin.1["capCoin"].doubleValue
                        let percent = coin.1["percent"].doubleValue
                        self.coins.append(Coin(ticker, initialPrice, currentPrice, allocation, capCoin, percent))
                    }
                    
                    self.coins.sort(by: {$0.ticker < $1.ticker})
                    self.coins.sort(by: {$0.allocation > $1.allocation})

                
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
        }
    }
    
    
    func updateCoinPrices(completion: @escaping (_ success: Bool) -> Void) {
        let url = URL(string: Constants.API + "game/prices/" + self.id)!
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                // Get all coin prices, default CapCoin allocation to 0
                for coin in json["prices"] {
                    let ticker = coin.0
                    let currentPrice = coin.1.doubleValue
                    var x = 0
                    for storedCoin in self.coins {
                        if ticker == storedCoin.ticker {
                            self.coins[x].currentPrice = currentPrice
                            break
                        }
                        x += 1
                    }
                }
                
                self.coins.sort(by: {$0.ticker < $1.ticker})
                self.coins.sort(by: {$0.allocation > $1.allocation})
                
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
}
