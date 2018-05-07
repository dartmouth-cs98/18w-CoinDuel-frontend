//
//  Coin.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/20/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Coin {
    var ticker:String
    var initialPrice:Double = 0.0
    var currentPrice:Double = 0.0
    var allocation:Double = 0.0
    var capCoinReturn:Double = 0.0
    var percentReturn:Double = 0.0
    var logoUrl = ""
    
    init(_ ticker:String, _ allocation:Double, _ initialPrice:Double) {
        self.ticker = ticker
        self.initialPrice = initialPrice
        self.currentPrice = 0.0
        self.allocation = allocation
        self.capCoinReturn = 0.0
        self.percentReturn = 0.0
        self.logoUrl = ""
    }
    
    init(_ ticker:String, _ initialPrice:Double, _ currentPrice:Double, _ allocation:Double, _ capCoinReturn:Double, _ percentReturn:Double) {
        self.ticker = ticker
        self.initialPrice = initialPrice
        self.currentPrice = currentPrice
        self.allocation = allocation
        self.capCoinReturn = capCoinReturn
        self.percentReturn = percentReturn
        self.logoUrl = ""
    }
    
    // Retrieves the coin's logo
    func getCoinLogo(completion: @escaping (_ success: Bool) -> Void) {
        
        let apiUrl = URL(string: Constants.API + "coin/logo/" + self.ticker)
        
        Alamofire.request(apiUrl!, method: HTTPMethod.get, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            
            if let statusCode = response.response?.statusCode {
                if (statusCode == 200){
                    do{
                        var json = try JSON(data: response.data!)
                        self.logoUrl = json["url"].stringValue
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
