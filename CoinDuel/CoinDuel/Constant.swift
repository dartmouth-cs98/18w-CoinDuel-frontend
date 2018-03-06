//
//  Constant.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/15/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let API = "https://coinduel-cs98.herokuapp.com/api/"
//    static let API = "http://localhost:9000/api/"
    
    static let MissingEntryError = "responseValidationFailed(Alamofire.AFError.ResponseValidationFailureReason.unacceptableStatusCode(422))"
    
    static let greenColor = UIColor(red:CGFloat(85.0/255.0), green:CGFloat(223.0/255.0), blue:CGFloat(133.0/255.0), alpha:1.0)
    static let redColor = UIColor(red:CGFloat(232/255.0), green:CGFloat(60.0/255.0), blue:CGFloat(48.0/255.0), alpha:1.0)
    static let orangeColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(134.0/255.0), blue:CGFloat(119.0/255.0), alpha:1.0)
    static let lightBlueColor = UIColor(red:CGFloat(56.0/255.0), green:CGFloat(143.0/255.0), blue:CGFloat(201.0/255.0), alpha:1.0)
    static let darkRedColor = UIColor(red:CGFloat(232/255.0), green:CGFloat(60.0/255.0), blue:CGFloat(48.0/255.0), alpha:1.0)
    static let lightGrayColor = UIColor(red:CGFloat(192/255.0), green:CGFloat(192/255.0), blue:CGFloat(192/255.0), alpha:1.0)
}
