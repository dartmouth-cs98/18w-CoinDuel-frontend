////
////  Game.swift
////  CoinDuel
////
////  Created by Henry Wilson on 2/15/18.
////  Copyright © 2018 Capitalize. All rights reserved.
////
//
//import Foundation
//
//class Game {
//
//    struct CoinDuelGame: Codable {
//        var id: String
//        var startDate: Date
//        var finishDate: Date
//        
//        static let api = Constants.API + "game/"
//
//        init?(json: [String: Any]) {
//            guard let start = json["start_date"] as? String,
//                let finish = json["finish_date"] as? String,
//                let gameId = json["id"] as? Int else {
//                    return nil
//            }
//            self.startDate = start
//            self.finishDate = finish
//            self.id = gameId
//        }
//    }
//
//    // This method comes from a great tutorial I found on JSON APIs.
//    // https://grokswift.com/json-swift-4/
//    static func getCurrentGame(completionHandler: @escaping (CoinDuelGame?, Error?) -> Void) {
//    }
//
//}

