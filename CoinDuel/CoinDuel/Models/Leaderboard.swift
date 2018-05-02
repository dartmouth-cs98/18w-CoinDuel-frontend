//
//  File.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/19/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Leaderboard {
    
    var currentUsers:[User] = [User]()
    var allTimeUsers:[User] = [User]()
    var game: Game = Game()
    
    init() {
        self.currentUsers = [User]()
        self.allTimeUsers = [User]()
        self.game = Game()
    }

    func getLeaderboardForGame(gameID: String, completion: @escaping (_ finished: Bool) -> Void) {
        let url = URL(string: Constants.API + "leaderboard/" + gameID)!
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                self.currentUsers.removeAll()
                let jsonArray = JSON(value).arrayValue
                for obj in jsonArray {
                    let name = obj["userId"]["username"].stringValue
                    let coins = obj["coin_balance"].doubleValue
                    self.currentUsers.append(User(username: name, coinBalance: coins, rank: 0))
                }
                self.currentUsers = self.currentUsers.sorted(by: { $0.coinBalance > $1.coinBalance })
                completion(true)
            case .failure(let error):
                completion(false)
                print(error)
            }
        }
    }

    func getCurrentLeaderboard(completion: @escaping (_ success: Bool) -> Void) {
        self.game.getCurrentGame() { (success) -> Void in
            let url = URL(string: Constants.API + "leaderboard/" + self.game.id)!
            Alamofire.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    self.currentUsers.removeAll()
                    let jsonArray = JSON(value).arrayValue
                    for obj in jsonArray {
                        let name = obj["userId"]["username"].stringValue
                        let coins = obj["coin_balance"].doubleValue
                        
                        // do not display cell with no name user (user has been deleted)
                        if (name != "") {
                            self.currentUsers.append(User(username: name, coinBalance: coins, rank: 0))
                        }
                    }
                    self.currentUsers = self.currentUsers.sorted(by: { $0.coinBalance > $1.coinBalance })
                    
                    // catch an empty game
                    if (self.currentUsers.count == 0) {
                        self.currentUsers.append(User(username: "No users in game", coinBalance: 0.0, rank: 0))
                    }
                    completion(true)
                case .failure(let error):
                    completion(false)
                    print(error)
                }
            }
        }
    }
    
    func getAllTimeLeaderboard(completion: @escaping (_ success: Bool) -> Void) {
        let url = URL(string: Constants.API + "leaderboard")!
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
                case .success(let value):
                    self.allTimeUsers.removeAll()
                    let jsonArray = JSON(value).arrayValue
                    for obj in jsonArray {
                        let name = obj["username"].stringValue
                        let coins = obj["coin_balance"].doubleValue
                        self.allTimeUsers.append(User(username: name, coinBalance: coins, rank: 0))
                    }
                    self.allTimeUsers = self.allTimeUsers.sorted(by: { $0.coinBalance > $1.coinBalance })
                    completion(true)
                case .failure(let error):
                    completion(false)
                    print(error)
            }
        }
    }
}
