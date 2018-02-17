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
        self.game.retrieveCurrentGame(self)
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

        // Display varies depending on whether game is active
    
        if gameRunning {
            cell.coinAmountStepper.isHidden = true
        } else {
            cell.coinAmountStepper.isHidden = false
            self.game.amounts[indexPath.row] = cell.coinAmountStepper.value
            
            let remaining = 10.0 - self.game.totalAmount()
            if remaining > 0.0 {
                self.submitButton.setTitle("Allocate " + String(Int(remaining)) + " additional CapCoin", for: UIControlState .normal)
                self.submitButton.isEnabled = false
            } else {
                self.submitButton.setTitle("Submit", for: UIControlState .normal)
                self.submitButton.isEnabled = true
            }
        }
        
        cell.coinNameLabel.text = self.game.coins[indexPath.row]
        cell.coinAmountLabel.text = String(Int(self.game.amounts[indexPath.row]))
        
        return cell
    }
    
    @IBAction func changeCoinAmount(_ sender: UIStepper, forEvent event: UIEvent) {
        gameTableView.reloadData()
    }
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        // Make necessary UI changes
        submitButton.isHidden = true
        gameRunning = true
        
        // Submit the entry to the server
        if !self.game.submitEntry() {
            print("Error")
        } else {
            self.game.updateGame(self)
        }

        // To-Do: Change constraints programatically so submit button area doesn't cover up Table View
        // tableViewConstraint.firstItem = SafeArea

    }


}

