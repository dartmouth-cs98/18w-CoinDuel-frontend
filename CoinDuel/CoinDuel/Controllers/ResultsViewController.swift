//
//  ResultsViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 2/23/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    var game: Game = Game()
    let numberFormatter = NumberFormatter()
    var leaderboard: Leaderboard = Leaderboard()
    var place: Int = 0
    @IBOutlet weak var capcoinResultLabel: UILabel!
    @IBOutlet weak var resultsText: UILabel!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var shakeGif: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var placeActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initial mining state
        self.submitButton.setTitle("PLEASE WAIT", for: .normal)
        self.submitButton.backgroundColor = Constants.orangeColor
        self.submitButton.isEnabled = false
        self.pageTitle.text = "MINING CAPCOIN"
        self.resultsText.text = ""
        self.capcoinResultLabel.text = ""
        
        // preload gif
        if let asset = NSDataAsset(name: "mining") {
            shakeGif.image = UIImage.gif(data: asset.data)
            shakeGif.layer.cornerRadius = 6.0
            shakeGif.clipsToBounds = true
        }
        
        // mine for user's balance
        let apiUrl = URL(string: Constants.blockchainUrl + "mine")
        let params = ["user": UserDefaults.standard.string(forKey:"id")!]
        Alamofire.request(apiUrl!, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            
            // mine success!
            if let statusCode = response.response?.statusCode {
                if (statusCode == 200){
                    do{
                        var json = try JSON(data: response.data!)       // parse to json
                        sleep(3)
                        
                        // load presets
                        self.shakeGif.isHidden = true
                        self.placeActivityIndicator.isHidden = false
                        self.submitButton.setTitle("COLLECT WINNINGS", for: .normal)
                        self.submitButton.backgroundColor = Constants.greenColor
                        self.submitButton.isEnabled = true
                        self.pageTitle.text = "GAME COMPLETE"
                        let defaults = UserDefaults.standard
                        let username = defaults.string(forKey: "username")
                        
                        // Number format
                        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
                        self.numberFormatter.minimumFractionDigits = 2
                        self.numberFormatter.maximumFractionDigits = 2
                        self.leaderboard.getLeaderboardForGame(gameID: self.game.id) { (success) in
                            if (success){
                                var numPlayers = self.leaderboard.currentUsers.count.description
                                for user in self.leaderboard.currentUsers {
                                    self.place += 1
                                    if (user.username == username!) {
                                        break
                                    }
                                }
                                
                                self.placeActivityIndicator.isHidden = true
                                self.resultsText.text = "You came in " + self.place.description + " out of " + numPlayers + " users!"
                            }
                        }
                        
                        // grab balance if success
                        if (json["success"].boolValue) {
                            print(json)
                            let balance = json["response"]["data"]["balances"][0]["capcoin"].floatValue
                            self.capcoinResultLabel.text = "You received " + self.numberFormatter.string(from: NSNumber(value: balance))! + " CC"
                        }
    
                        // unable to parse json
                    } catch{
                        print("error loading json")
                    }
                
                // unidentified error sent back
                } else {
                    print(response.data)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving Results VC")
            UserDefaults.standard.set(nil, forKey: "gameId")
        }
    }
}

