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
    
    var users:[User] = [User]()
    var game: Game = Game()
    
    init() {
        self.users = [User]()
        self.game = Game()
    }
        
    func getCurrentLeaderboard(_ leaderboardVC:LeaderboardViewController) {
        self.game.getCurrentGame() { (success) -> Void in
            if success {
                let url = URL(string: Constants.API + "leaderboard/" + self.game.id)!
                Alamofire.request(url, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let jsonArray = JSON(value).arrayValue
                        for obj in jsonArray {
                            let name = obj["userId"]["username"].stringValue
                            let coins = obj["coin_balance"].doubleValue
                            self.users.append(User(username: name, coinBalance: coins))
                        }
                        self.users = self.users.sorted(by: { $0.coinBalance > $1.coinBalance })
                        
                        DispatchQueue.main.async() {
                            leaderboardVC.leaderboardTable.reloadData()
                            leaderboardVC.firstPlaceLabel.text = self.users[0].username
                            leaderboardVC.secondPlaceLabel.text = self.users[1].username
                            leaderboardVC.thirdPlaceLabel.text = self.users[2].username
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                
            }
        }
    }
}
