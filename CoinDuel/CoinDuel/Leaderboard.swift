//
//  File.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/19/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

class Leaderboard {
    
    var users:[User] = [User]()
    
    init() {
        self.users = [User]()
    }
        
    func getCurrentLeaderboard(_ leaderboardVC:LeaderboardViewController) {
        let apiUrl = NSURL(string: Constants.API + "user")
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error connecting to server")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let response = json as? NSArray {
                    for key in response {
                        if let dict = key as? NSDictionary {
                            if let name = dict.value(forKey: "username") as? String, let coins = dict.value(forKey: "coinBalance") as? Int {
                                self.users.append(User(username: name, coinBalance: coins))
                            }
                        }
                    }
                    self.users = self.users.sorted(by: { $0.coinBalance > $1.coinBalance })
                }
            }
            
            DispatchQueue.main.async() {
                leaderboardVC.leaderboardTable.reloadData()
                leaderboardVC.firstPlaceLabel.text = self.users[0].username
                leaderboardVC.secondPlaceLabel.text = self.users[1].username
                leaderboardVC.thirdPlaceLabel.text = self.users[2].username
            }
        }
        
        task.resume()
    }
}
