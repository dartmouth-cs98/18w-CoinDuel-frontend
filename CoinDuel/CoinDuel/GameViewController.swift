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
    @IBOutlet weak var submitButton: UIButton!
    
    var game: Game = Game()
    var gameRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameRunning = false
        self.game.getCurrentGame(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.game.coins.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GameTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
        }
        
        cell.coinNameLabel.text = self.game.coins[indexPath.row]
        cell.coinPriceLabel.text = String(self.game.prices[indexPath.row])
        
        // Display varies depending on whether game is active
    
        if gameRunning {
            cell.coinPriceLabel.isHidden = false
            cell.choiceSwitch.isHidden = true
            
            // Hide the cell completely if not selected
            if !cell.choiceSwitch.isOn {
                self.game.selections[indexPath.row] = false
                cell.isHidden = true
            } else {
                self.game.selections[indexPath.row] = true
                cell.isHidden = false
            }
        } else {
            cell.coinPriceLabel.isHidden = true
            cell.choiceSwitch.isHidden = false
            
            // Check to see which coins are toggled
            if cell.choiceSwitch.isOn {
                print("Here")
            }
        }
        
        return cell
    }
    
    // Got this idea for hiding cells from: (used for hiding ones not chosen for game)
    // https://stackoverflow.com/questions/29886642/hide-uitableview-cell/29888552
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if gameRunning && !self.game.selections[indexPath.row] {
            return 0.0
        } else {
            return tableView.rowHeight
        }
    }
    
    @IBAction func toggleCoin(_ sender: UISwitch) {
        gameTableView.reloadData()
    }
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        submitButton.isHidden = true
        gameRunning = true
//        tableViewConstraint.firstItem = SafeArea
        gameTableView.reloadData()
    }


}

