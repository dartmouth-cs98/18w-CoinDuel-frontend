//
//  Constant.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

struct Constants {
//    static let API = "https://coinduel-cs98.herokuapp.com/api/"
    static let API = "http://localhost:9000/api/"
}

enum ServerError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}
