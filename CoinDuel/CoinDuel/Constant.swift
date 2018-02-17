//
//  Constant.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation

struct Constants {
    static let API = "https://coinduel-cs98.herokuapp.com/api/"
//    static let API = "http://localhost:9000/api/"
    static let TEMP_USER_ID = "5a8607d4971c50fbf29726a2" // Get rid of this once authentication enabled
}   

enum ServerError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}
