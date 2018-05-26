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
//    static let API = "https://coinduel-cs98.herokuapp.com/api/"
    static let API = "http://localhost:9000/api/"

    static let MissingEntryError = "responseValidationFailed(Alamofire.AFError.ResponseValidationFailureReason.unacceptableStatusCode(422))"
    
    static let greenColor = UIColor(red:CGFloat(85.0/255.0), green:CGFloat(223.0/255.0), blue:CGFloat(133.0/255.0), alpha:1.0)
    static let redColor = UIColor(red:CGFloat(232/255.0), green:CGFloat(60.0/255.0), blue:CGFloat(48.0/255.0), alpha:1.0)
    static let orangeColor = UIColor(red:CGFloat(255.0/255.0), green:CGFloat(134.0/255.0), blue:CGFloat(119.0/255.0), alpha:1.0)
    static let lightBlueColor = UIColor(red:CGFloat(56.0/255.0), green:CGFloat(143.0/255.0), blue:CGFloat(201.0/255.0), alpha:1.0)
    static let darkRedColor = UIColor(red:CGFloat(232/255.0), green:CGFloat(60.0/255.0), blue:CGFloat(48.0/255.0), alpha:1.0)
    static let lightGrayColor = UIColor(red:CGFloat(192/255.0), green:CGFloat(192/255.0), blue:CGFloat(192/255.0), alpha:1.0)
}

// Copying this extension from https://www.markusbodner.com/2017/06/20/how-to-verify-and-limit-decimal-number-inputs-in-ios-with-swift/
extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        // Use NumberFormatter to check if we can turn the string into a number
        // and to get the locale specific decimal separator.
        let formatter = NumberFormatter()
        formatter.allowsFloats = true // Default is true, be explicit anyways
        let decimalSeparator = formatter.decimalSeparator ?? "."  // Gets the locale specific decimal separator. If for some reason there is none we assume "." is used as separator.
        
        // Check if we can create a valid number. (The formatter creates a NSNumber, but
        // every NSNumber is a valid double, so we're good!)
        if formatter.number(from: self) != nil {
            // Split our string at the decimal separator
            let split = self.components(separatedBy: decimalSeparator)
            
            // Depending on whether there was a decimalSeparator we may have one
            // or two parts now. If it is two then the second part is the one after
            // the separator, aka the digits we care about.
            // If there was no separator then the user hasn't entered a decimal
            // number yet and we treat the string as empty, succeeding the check
            let digits = split.count == 2 ? split.last ?? "" : ""
            
            // Finally check if we're <= the allowed digits
            return digits.count <= maxDecimalPlaces
        }
        
        return false // couldn't turn string into a valid number
    }
}
