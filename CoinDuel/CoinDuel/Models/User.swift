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
    
    init(username: String?, coinBalance: Double) {
        self.username = username ?? ""
        self.coinBalance = coinBalance
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
