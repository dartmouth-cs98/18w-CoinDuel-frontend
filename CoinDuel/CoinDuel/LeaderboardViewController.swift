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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leaderboard.getCurrentLeaderboard(self)
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
        allTimeButton.layer.borderColor = (UIColor.lightGray).cgColor;
        currentButton.layer.borderColor = (UIColor.lightGray).cgColor;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboard.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let user = self.leaderboard.users[indexPath.row]
        cell.placeLabel.text = String(indexPath.row + 1)
        cell.nameLabel.text = user.username
        cell.scoreLabel.text = String(user.coinBalance)
    
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

    @IBAction func allTimeClick(_ sender: Any) {
        allTimeButton.backgroundColor = UIColor.red
        currentButton.backgroundColor = UIColor(red: 0.1216, green: 0.1961, blue: 0.5294, alpha: 1.0)
        allTimeButton.layer.borderWidth = 0;
        currentButton.layer.borderWidth = 2.0;
    }
    
    @IBAction func currentClick(_ sender: Any) {
        allTimeButton.backgroundColor = UIColor(red: 0.1216, green: 0.1961, blue: 0.5294, alpha: 1.0)
        currentButton.backgroundColor = UIColor.red
        allTimeButton.layer.borderWidth = 2.0;
        currentButton.layer.borderWidth = 0;
    }
}
