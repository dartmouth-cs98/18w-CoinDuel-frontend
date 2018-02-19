//
//  GameViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 1/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var gameReturnLabel: UILabel!
    @IBOutlet weak var gameStatusSubheaderLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var nextGameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButton!
    
    var game: Game = Game()
    var gameRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameRunning = false
        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false
        gameReturnLabel.isHidden = true
        gameStatusLabel.isHidden = true
        gameStatusSubheaderLabel.isHidden = true
        
        self.submitButton.setTitle("Allocate 10 additional CapCoin", for: UIControlState .normal)
        self.submitButton.isEnabled = false
        
        print("Updating")
        self.game.retrieveUpdatedGame(self)
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
        
        cell.gameVC = self
        cell.game = game // Give the cell access to the game so it can increment coinAmount
        cell.indexPath = indexPath.row

        // Display varies depending on whether game is active
    
        if gameRunning {
            cell.coinAmountStepper.isHidden = true
            cell.coinAmountLabel.isHidden = true
            cell.coinPriceLabel.isHidden = false
            cell.coinReturnLabel.isHidden = false
            cell.coinNameLabel.text = self.game.coins[indexPath.row] + " (" + String(Int(self.game.amounts[indexPath.row])) + ")"
        } else {
            cell.coinAmountStepper.isHidden = false
            cell.coinAmountLabel.isHidden = false
            cell.coinPriceLabel.isHidden = true
            cell.coinReturnLabel.isHidden = true
            
            cell.coinAmountStepper.value = self.game.amounts[indexPath.row]
            
            let remaining = 10.0 - self.game.totalAmount()
            if remaining > 0.0 {
                self.submitButton.setTitle("Allocate " + String(Int(remaining)) + " additional CapCoin", for: UIControlState .normal)
                self.submitButton.isEnabled = false
            } else {
                self.submitButton.setTitle("Submit", for: UIControlState .normal)
                self.submitButton.isEnabled = true
            }
            cell.coinNameLabel.text = self.game.coins[indexPath.row]
            cell.coinAmountLabel.text = String(Int(self.game.amounts[indexPath.row]))
        }
        
        
        return cell
    }
    
    func networkError() {
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        let alert = UIAlertController(title: "Network Error", message: "We could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        // Make necessary UI changes
        submitButton.isHidden = true
        gameRunning = true
        nextGameLabel.isHidden = true
        gameTimeLabel.isHidden = true
        gameReturnLabel.isHidden = false
        gameStatusLabel.isHidden = false
        gameStatusSubheaderLabel.isHidden = false
        
        // Submit the entry to the server
        self.game.submitEntry(self)

        // To-Do: Change constraints programatically so submit button area doesn't cover up Table View
        // tableViewConstraint.firstItem = SafeArea

    }


}

