//
//  User.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/17/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class User {
    var username: String
    var coinBalance: Double
    var rank: Int
    var profilePicture: String

    init() {
        self.username = ""
        self.coinBalance = 0
        self.rank = 0
        self.profilePicture = ""
    }
    
    init(username: String?, coinBalance: Double, rank: Int, profilePicture: String) {
        self.username = username ?? ""
        self.coinBalance = coinBalance
        self.rank = rank
        self.profilePicture = profilePicture
    }
    
    // retrieves user's all time rank
    func updateRankAllTime(completion: @escaping (_ success: Bool) -> Void) {
        
        let url = URL(string: Constants.API + "leaderboard")!
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let jsonArray = JSON(value).arrayValue
                var rank = 1
                for obj in jsonArray {
                    if (obj["username"].stringValue == self.username) {
                        self.rank = rank
                        break
                    }
                    rank += 1
                }
                completion(true)
            case .failure(let error):
                completion(false)
                print(error)
            }
        }
    }
    
    // Retrieves the user's coin balance
    func updateCoinBalance(completion: @escaping (_ success: Bool) -> Void) {

        let params = ["username": self.username]
        let apiUrl = URL(string: Constants.API + "user")

        Alamofire.request(apiUrl!, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in

            if let statusCode = response.response?.statusCode {
                if (statusCode == 200){
                    do{
                        var json = try JSON(data: response.data!)
                        if let coinBalance = json["coinBalance"].double {
                            self.coinBalance = coinBalance
                        }
                        
                        // store profile picture for leaderboard
                        self.profilePicture = json["profile_url"].string!
                        completion(true)
                    } catch{
                        print("error loading json")
                        completion(false)
                    }
                }
            }
        })
    }
}
