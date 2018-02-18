//
//  LeaderboardViewController.swift
//  CoinDuel
//
//  Created by Mitchell Revers on 2/1/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var firstPlaceLabel: UILabel!
    @IBOutlet weak var secondPlaceLabel: UILabel!
    @IBOutlet weak var thirdPlaceLabel: UILabel!
    
    var users = [User]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let user = users[indexPath.row]
        cell.placeLabel.text = String(indexPath.row + 1) + "."
        cell.nameLabel.text = user.username
        cell.scoreLabel.text = String(user.coinBalance)
    
        if user.username == UserDefaults.standard.string(forKey:"username") {
            cell.placeLabel.textColor = UIColor.red
            cell.nameLabel.textColor = UIColor.red
            cell.scoreLabel.textColor = UIColor.red
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiUrl = NSURL(string:Constants.API + "user");
        let request = NSMutableURLRequest(url:apiUrl! as URL);
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error connecting to server")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let response = json as? NSArray {
                    for key in response {
                        if let dict = key as? NSDictionary {
                            if let name = dict.value(forKey: "username") as? String, let coins = dict.value(forKey: "coinBalance") as? Int {
                                self.users.append(User(username: name, coinBalance: coins))
                            }
                        }
                    }
                    self.users = self.users.sorted(by: { $0.coinBalance > $1.coinBalance })
                }
            }
            
            DispatchQueue.main.async() {
                self.leaderboardTable.reloadData()
                self.firstPlaceLabel.text = self.users[0].username
                self.secondPlaceLabel.text = self.users[1].username
                self.thirdPlaceLabel.text = self.users[2].username
            }
        }
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
