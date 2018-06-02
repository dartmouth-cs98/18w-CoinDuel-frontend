//
//  LeaderboardViewController.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/1/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var allTimeButton: UIButton!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var firstNumberLabel: UILabel!
    @IBOutlet weak var secondNumberLabel: UILabel!
    @IBOutlet weak var thirdNumberLabel: UILabel!
    @IBOutlet weak var firstPlaceImage: UIImageView!
    @IBOutlet weak var secondPlaceImage: UIImageView!
    @IBOutlet weak var thirdPlaceImage: UIImageView!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var firstPlaceLabel: UILabel!
    @IBOutlet weak var secondPlaceLabel: UILabel!
    @IBOutlet weak var thirdPlaceLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var leaderboard: Leaderboard = Leaderboard()
    var numberFormatter: NumberFormatter = NumberFormatter()
    let refreshControl = UIRefreshControl()
    
    var isCurrent = false
    var game: Game = Game()
    
    // button colors
    var activeButtonColor = UIColor(red:0.91, green:0.24, blue:0.19, alpha:1.0)
    
    // custom grey
    var grey80 = UIColor(red:1, green:1, blue:1, alpha:0.5)
    
    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show activity indicator
        self.loadingActivityIndicatorView.startAnimating()
        self.loadingActivityIndicatorView.isHidden = false

        // From https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        if #available(iOS 10.0, *) {
            refreshControl.tintColor = UIColor.white
            self.leaderboardTable.refreshControl = refreshControl
        } else {
            self.leaderboardTable.addSubview(refreshControl)
        }

        // Add refresh control function
        refreshControl.addTarget(self, action: #selector(refreshLeaderboardData(_:)), for: .valueChanged)
        
        let imageViews = [firstPlaceImage, secondPlaceImage, thirdPlaceImage]
        for image in imageViews {
            image!.layer.cornerRadius = image!.frame.height/2;
            image!.clipsToBounds = true;
        }
        
        let numberLabels = [firstNumberLabel, secondNumberLabel, thirdNumberLabel]
        for label in numberLabels {
            label!.layer.masksToBounds = true
            label!.layer.cornerRadius = 11
        }
        
        allTimeButton.layer.masksToBounds = true
        allTimeButton.layer.cornerRadius = allTimeButton.frame.height / 2
        allTimeButton.layer.borderWidth = 0.0;
        allTimeButton.layer.borderColor = grey80.cgColor;
        allTimeButton.backgroundColor = activeButtonColor
        
        currentButton.layer.masksToBounds = true
        currentButton.layer.cornerRadius = currentButton.frame.height / 2
        currentButton.layer.borderWidth = 0.5;
        currentButton.layer.borderColor = grey80.cgColor;
        currentButton.backgroundColor = UIColor.clear
        
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        // start in all time leaderboard
        self.isCurrent = false
        
        // disable current game button if game is not active
        if (!self.game.isActive) {
            self.currentButton.isEnabled = false
            self.currentButton.alpha = 0.35
        }
        
        self.leaderboard.getAllTimeLeaderboard() { (success) -> Void in
            self.getLeaderBoardHelper(success: success)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCurrent {
            if (self.game.isActive){
                return self.leaderboard.currentUsers.count
            } else{
                return 0
            }
        } else {
            return self.leaderboard.allTimeUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        var user = User(username: "", coinBalance: 0.0, rank: 0, profilePicture: "profile")
        if self.isCurrent {
            user = self.leaderboard.currentUsers[indexPath.row]
        } else {
            user = self.leaderboard.allTimeUsers[indexPath.row]
        }
        
        cell.placeLabel.text = String(indexPath.row + 1)
        cell.scoreLabel.text = numberFormatter.string(from: NSNumber(value: user.coinBalance))! + " CC"
        cell.nameLabel.text = user.username
    
        // different cell for current user
        cell.nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        if user.username == UserDefaults.standard.string(forKey:"username") {
            cell.nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refreshLeaderboardData(_ sender:Any) {
        // show activity indicator
//        self.loadingActivityIndicatorView.startAnimating()
//        self.loadingActivityIndicatorView.isHidden = false
        
        // load leadboard
        if self.isCurrent {
            self.leaderboard.getCurrentLeaderboard() { (success) -> Void in
                self.getLeaderBoardHelper(success: success)
            }
        } else {
            self.leaderboard.getAllTimeLeaderboard() { (success) -> Void in
                self.getLeaderBoardHelper(success: success)
            }
        }
    }


    @IBAction func allTimeClick(_ sender: Any) {
        // load all time leaderboard
        if self.isCurrent {
            // show activity indicator
//            self.loadingActivityIndicatorView.startAnimating()
//            self.loadingActivityIndicatorView.isHidden = false
            
            // reset views
            allTimeButton.backgroundColor = activeButtonColor
            currentButton.backgroundColor = UIColor.clear
            allTimeButton.layer.borderWidth = 0.0;
            currentButton.layer.borderWidth = 0.5;
            self.leaderboard.getAllTimeLeaderboard() { (success) -> Void in
                self.isCurrent = false
                self.getLeaderBoardHelper(success: success)
            }
        }
    }
    
    @IBAction func currentClick(_ sender: Any) {
        // load current leaderboard
        if !self.isCurrent {
            // show activity indicator
//            self.loadingActivityIndicatorView.startAnimating()
//            self.loadingActivityIndicatorView.isHidden = false
            
            // reset views
            allTimeButton.backgroundColor = UIColor.clear
            currentButton.backgroundColor = activeButtonColor
            allTimeButton.layer.borderWidth = 0.5;
            currentButton.layer.borderWidth = 0.0;
            self.leaderboard.getCurrentLeaderboard() { (success) -> Void in
                self.isCurrent = true
                self.getLeaderBoardHelper(success: success)
            }
        }
    }

    @IBAction func onXPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving leaderboard VC")
        }
    }

    func networkError(_ errorMessage:String) {
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        let alert = UIAlertController(title: "Uh oh!", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getLeaderBoardHelper(success:Bool) {
        // hide all profile pictures
        self.firstPlaceImage.isHidden = true
        self.secondPlaceImage.isHidden = true
        self.thirdPlaceImage.isHidden = true
        self.firstNumberLabel.isHidden = true
        self.secondNumberLabel.isHidden = true
        self.thirdNumberLabel.isHidden = true
        
        // get leaderboard
        if (success) {
            DispatchQueue.main.async() {
                self.leaderboardTable.reloadData()
                var users:[User] = [User]()
                if self.isCurrent {
                    users = self.leaderboard.currentUsers
                    if (!self.game.isActive){
                        users = [User]()
                    }
                } else {
                    users = self.leaderboard.allTimeUsers
                }
                
                // add name to place labels
                self.firstPlaceLabel.text = users.count > 0 ? users[0].username : ""
                self.secondPlaceLabel.text = users.count > 1 ? users[1].username : ""
                self.thirdPlaceLabel.text = users.count > 2 ? users[2].username : ""
                
                // asynchronously add profile picture to name labels if current game
                if self.isCurrent {
                    
                    // first place profile picture
                    if users.count > 0 {
                        users[0].updateCoinBalance { (success) in
                            if (success){
                                self.firstPlaceImage.image = UIImage(named: users[0].profilePicture)
                                self.firstPlaceImage.isHidden = false
                                self.firstNumberLabel.isHidden = false
                            }
                        }
                    }
                    
                    // second place profile picture
                    if users.count > 1 {
                        users[1].updateCoinBalance { (success) in
                            if (success){
                                self.secondPlaceImage.image = UIImage(named: users[1].profilePicture)
                                self.secondPlaceImage.isHidden = false
                                self.secondNumberLabel.isHidden = false
                            }
                        }
                    }
                    
                    // third place profile picture
                    if users.count > 2 {
                        users[2].updateCoinBalance { (success) in
                            if (success){
                                self.thirdPlaceImage.image = UIImage(named: users[2].profilePicture)
                                self.thirdPlaceImage.isHidden = false
                                self.thirdNumberLabel.isHidden = false
                            }
                        }
                    }
                    
                // add profile pictures to place images if all time rankings
                } else {
                    
                    // first place profile picture
                    if users.count > 0 {
                        self.firstPlaceImage.image = UIImage(named: users[0].profilePicture)
                        self.firstPlaceImage.isHidden = false
                        self.firstNumberLabel.isHidden = false
                    }
                    
                    // second place profile picture
                    if users.count > 1 {
                        self.secondPlaceImage.image = UIImage(named: users[1].profilePicture)
                        self.secondPlaceImage.isHidden = false
                        self.secondNumberLabel.isHidden = false
                    }
                    
                    // third place profile picture
                    if users.count > 2 {
                        self.thirdPlaceImage.image = UIImage(named: users[2].profilePicture)
                        self.thirdPlaceImage.isHidden = false
                        self.thirdNumberLabel.isHidden = false
                    }
                }
            
                // hide activity
                self.refreshControl.endRefreshing()
                self.loadingActivityIndicatorView.stopAnimating()
                self.loadingActivityIndicatorView.isHidden = true
            }
        }
        else {
            DispatchQueue.main.async() {
                self.leaderboardTable.reloadData()
                
                // reset labels
                self.firstPlaceLabel.text = ""
                self.secondPlaceLabel.text = ""
                self.thirdPlaceLabel.text = ""
                
                // reset images
                self.firstPlaceImage.image = UIImage(named: "profile")
                self.secondPlaceImage.image = UIImage(named: "profile")
                self.thirdPlaceImage.image = UIImage(named: "profile")
                    
                self.refreshControl.endRefreshing()
                self.loadingActivityIndicatorView.stopAnimating()
                self.loadingActivityIndicatorView.isHidden = true
            }
        }
    }
}
