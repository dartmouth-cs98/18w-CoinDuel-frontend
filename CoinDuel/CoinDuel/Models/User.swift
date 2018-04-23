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
                        user_id = json["user"]["_id"].description
                        authToken = json["token"].description
                        profileUrl = json["user"]["profile_url"].description
                        self.validated = true
                    } catch{
                        print("error loading json")
                    }
                }
            }

            DispatchQueue.main.async() {
                if (self.validated) {
                    let defaults = UserDefaults.standard
                    defaults.set(user, forKey: "username")
                    defaults.set(user_id, forKey: "id")
                    defaults.set(profileUrl, forKey: "profileImage")
                    defaults.set(authToken, forKey: "authToken")

                    //call main storyboard once succesful sign in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LandingPageViewController") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    self.failedLogin.isHidden = false
                }
            }
        })



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
