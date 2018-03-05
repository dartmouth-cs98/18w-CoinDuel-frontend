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
        var json = [String: String]()
        json["username"] = self.username
        
        // Credit for following API technique: https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
        if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
            let url = URL(string: Constants.API + "user")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            print(request)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                // Error checking
                guard error == nil else {
                    completion(false)
                    return
                }
                
                let json = JSON(data!)
                print(json)
                
                self.coinBalance = json["coinBalance"].doubleValue
                completion(true)
            }
            
            task.resume()
        } else {
            print("Failed conversion to JSON")
            completion(false)
        }
    }
}
