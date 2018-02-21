//
//  Coin.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/20/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

struct Coin {
    var ticker:String
    var initialPrice:Double = 0.0
    var currentPrice:Double = 0.0
    var allocation:Double = 0.0
    var capCoinReturn:Double = 0.0
    var percentReturn:Double = 0.0
    
    init(_ ticker:String, _ allocation:Double) {
        self.ticker = ticker
        self.initialPrice = 0.0
        self.currentPrice = 0.0
        self.allocation = allocation
        self.capCoinReturn = 0.0
        self.percentReturn = 0.0
    }
    
    init(_ ticker:String, _ initialPrice:Double, _ currentPrice:Double, _ allocation:Double, _ capCoinReturn:Double, _ percentReturn:Double) {
        self.ticker = ticker
        self.initialPrice = initialPrice
        self.currentPrice = currentPrice
        self.allocation = allocation
        self.capCoinReturn = capCoinReturn
        self.percentReturn = percentReturn
    }
}
