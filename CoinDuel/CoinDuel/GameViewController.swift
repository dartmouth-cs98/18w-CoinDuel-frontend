//
//  GameViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 1/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var gameTableView: UITableView!
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    let coins = ["Bitcoin", "Litecoin", "Ethereum", "Monero", "Ripple", "Bitcoin Cash"]
    var prices = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    
    var gameRunning = false
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scoreLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GameTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
        }
        
        cell.coinNameLabel.text = coins[indexPath.row]
        cell.coinPriceLabel.text = String(prices[indexPath.row])
        
        if gameRunning {
            cell.coinPriceLabel.isHidden = false
            cell.choiceSwitch.isHidden = true
        } else {
            cell.coinPriceLabel.isHidden = true
            cell.choiceSwitch.isHidden = false
        }
        
        return cell
    }
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        submitButton.isHidden = true
        gameRunning = true
//        tableViewConstraint.firstItem = SafeArea
        gameTableView.reloadData()
    }


}

