//
//  User.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/17/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

class User {
    var username: String
    var coinBalance: Int
    
    init(username: String?, coinBalance: Int) {
        self.username = username ?? ""
        self.coinBalance = coinBalance
    }
}
