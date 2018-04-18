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
    var leaderboard: Leaderboard = Leaderboard()
    var numberFormatter: NumberFormatter = NumberFormatter()
    let refreshControl = UIRefreshControl()
    var isCurrent = true

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // From https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        if #available(iOS 10.0, *) {
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
        allTimeButton.layer.cornerRadius = 10
        currentButton.layer.masksToBounds = true
        currentButton.layer.cornerRadius = 10
        
        allTimeButton.layer.borderWidth = 2.0;
        allTimeButton.layer.borderColor = (UIColor.white).cgColor;
        currentButton.layer.borderColor = (UIColor.white).cgColor;
        
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        self.leaderboard.getCurrentLeaderboard() { (success) -> Void in
            self.getLeaderBoardHelper(success: success)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCurrent {
            if (self.leaderboard.game.isActive){
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
        
        var user = User(username: "", coinBalance: 0.0)
        if self.isCurrent {
            user = self.leaderboard.currentUsers[indexPath.row]
        } else {
            user = self.leaderboard.allTimeUsers[indexPath.row]
        }
        
        cell.placeLabel.text = String(indexPath.row + 1)
        cell.nameLabel.text = user.username
        cell.scoreLabel.text = numberFormatter.string(from: NSNumber(value: user.coinBalance))! + " CC"
    
        if user.username == UserDefaults.standard.string(forKey:"username") {
            cell.placeLabel.textColor = UIColor.red
            cell.nameLabel.textColor = UIColor.red
            cell.scoreLabel.textColor = UIColor.red
        } else {
            cell.placeLabel.textColor = UIColor.black
            cell.nameLabel.textColor = UIColor.black
            cell.scoreLabel.textColor = UIColor.black
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refreshLeaderboardData(_ sender:Any) {
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
        if self.isCurrent {
            allTimeButton.backgroundColor = Constants.greenColor
            currentButton.backgroundColor = Constants.lightBlueColor
            allTimeButton.layer.borderWidth = 0.0;
            currentButton.layer.borderWidth = 2.0;
            self.leaderboard.getAllTimeLeaderboard() { (success) -> Void in
                self.getLeaderBoardHelper(success: success)
            }
            self.isCurrent = false
        }
    }
    
    @IBAction func currentClick(_ sender: Any) {
        if !self.isCurrent {
            allTimeButton.backgroundColor = Constants.lightBlueColor
            currentButton.backgroundColor = Constants.greenColor
            allTimeButton.layer.borderWidth = 2.0;
            currentButton.layer.borderWidth = 0.0;
            self.leaderboard.getCurrentLeaderboard() { (success) -> Void in
                self.getLeaderBoardHelper(success: success)
            }
            self.isCurrent = true
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
        if (success) {
            DispatchQueue.main.async() {
                self.leaderboardTable.reloadData()
                var users:[User] = [User]()
                if self.isCurrent {
                    users = self.leaderboard.currentUsers
                    if (!self.leaderboard.game.isActive){
                        users = [User]()
                    }
                } else {
                    users = self.leaderboard.allTimeUsers
                }
                
                self.firstPlaceLabel.text = users.count > 0 ? users[0].username : ""
                self.secondPlaceLabel.text = users.count > 1 ? users[1].username : ""
                self.thirdPlaceLabel.text = users.count > 2 ? users[2].username : ""
                
                self.refreshControl.endRefreshing()
            }
        }
        else {
            DispatchQueue.main.async() {
                self.leaderboardTable.reloadData()
                self.firstPlaceLabel.text = ""
                self.secondPlaceLabel.text = ""
                self.thirdPlaceLabel.text = ""
                
                self.refreshControl.endRefreshing()
            }
        }
    }
}
