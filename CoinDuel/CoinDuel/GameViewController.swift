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
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    var game: Game = Game()
    var isGameDisplayMode: Bool = false
    var isPercentReturnMode: Bool = false
    let refreshControl = UIRefreshControl()
    let numberFormatter = NumberFormatter()

    
    // Completion blocks from https://stackoverflow.com/questions/35357807/running-one-function-after-another-completes
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // From https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        if #available(iOS 10.0, *) {
            self.gameTableView.refreshControl = refreshControl
        } else {
            self.gameTableView.addSubview(refreshControl)
        }
        
        // Add refresh control function
        refreshControl.addTarget(self, action: #selector(refreshPriceData(_:)), for: .valueChanged)
        
        // Number format
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        self.game.getCurrentGame() { (success) -> Void in
            if success {
                self.game.updateGame() { (entryStatus) -> Void in
                    if entryStatus == "entry" {
                        // Already has an entry for this game, check if it's started already
                        if self.game.isActive {
                            // Update prices
                            self.game.updateCoinPrices() { (coinSuccess) -> Void in
                                if coinSuccess {
                                    // Show price page with returns
                                    self.displayGameMode()
                                } else {
                                    self.networkError()
                                }
                            }
                        } else {
                            // Show the entry view
                            self.displayEntryMode()
                        }
                    } else if entryStatus == "none" {
                        // No entry yet, show the entry view
                        self.displayEntryMode()
                    } else {
                        self.networkError()
                    }
                }
            } else {
                self.networkError()
            }
        }
        
    }
    
    func displayEntryMode() {
        self.isGameDisplayMode = false
        
        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false

        gameReturnLabel.isHidden = true
        gameStatusLabel.isHidden = true
        gameStatusSubheaderLabel.isHidden = true
        
        self.submitButton.setTitle("Allocate 10 additional CapCoin", for: UIControlState .normal)
        self.submitButton.isEnabled = false
        self.submitButton.isHidden = false
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    func displayGameMode() {
        self.isGameDisplayMode = true
        
        gameReturnLabel.text = "+ " + String(Double(Int(self.game.totalReturn() * 100)) / 100.00) + " CC"

        if (self.game.totalReturn() > 0) {
            gameReturnLabel.backgroundColor = Constants.greenColor
        } else {
            gameReturnLabel.backgroundColor = Constants.redColor
        }
        
        gameReturnLabel.isHidden = false
        gameStatusLabel.isHidden = false
        gameStatusSubheaderLabel.isHidden = false
        
        nextGameLabel.isHidden = true
        gameTimeLabel.isHidden = true
        self.submitButton.isHidden = true
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    @objc func refreshPriceData(_ sender:Any) {
        if self.isGameDisplayMode && self.game.isActive {
            self.game.updateCoinPrices() { (coinSuccess) -> Void in
                if coinSuccess {
                    // Show price page with returns
                    DispatchQueue.main.async() {
                        self.gameTableView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.loadingActivityIndicatorView.stopAnimating()
//                        self.loadingActivityIndicatorView.isHidden = true
                    }
                } else {
                    self.networkError()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.game.coins.count
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
        
        let coin = self.game.coins[indexPath.row]
    
        if isGameDisplayMode {
            cell.coinAmountStepper.isHidden = true
            cell.coinAmountLabel.isHidden = true
            cell.coinPriceLabel.isHidden = false
            cell.coinReturnLabel.isHidden = false
            
            cell.coinNameLabel.text = coin.ticker + " (" + String(Int(coin.allocation)) + " CC)"
            cell.coinPriceLabel.text = "$" + numberFormatter.string(from: NSNumber(value: coin.currentPrice))!
            
            if self.isPercentReturnMode {
                cell.coinReturnLabel.text = numberFormatter.string(from: NSNumber(value: coin.percentReturn))! + "%"
            } else {
                cell.coinReturnLabel.text = numberFormatter.string(from: NSNumber(value: coin.capCoinReturn))! + " CC"
            }

            if (coin.percentReturn > 0) {
                cell.coinReturnLabel.backgroundColor = Constants.greenColor
            } else {
                print("Red")
                cell.coinReturnLabel.backgroundColor = Constants.redColor
            }
            
        } else {
            cell.coinAmountStepper.isHidden = false
            cell.coinAmountLabel.isHidden = false
            cell.coinPriceLabel.isHidden = true
            cell.coinReturnLabel.isHidden = true
            
            cell.coinAmountStepper.value = coin.allocation
            
            let remaining = 10.0 - self.game.totalAmount()
            if remaining > 0.0 {
                self.submitButton.setTitle("Allocate " + String(Int(remaining)) + " additional CapCoin", for: UIControlState .normal)
                self.submitButton.isEnabled = false
            } else {
                self.submitButton.setTitle("Submit", for: UIControlState .normal)
                self.submitButton.isEnabled = true
            }
            cell.coinNameLabel.text = coin.ticker
            cell.coinAmountLabel.text = String(Int(coin.allocation))
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
        // Submit the entry to the server
        self.game.submitEntry() { (success) -> Void in
            if success {
                self.game.updateGame(completion: { (entryUpdate) in
                    if entryUpdate == "entry" && self.game.isActive {
                        // Update prices
                        self.game.updateCoinPrices() { (coinSuccess) -> Void in
                            if coinSuccess {
                                // Show price page with returns
                                self.displayGameMode()
                            } else {
                                self.networkError()
                            }
                        }
                    } else if !self.game.isActive {
                        self.submitButton.setTitle("Update choices", for: UIControlState .normal)
                    } else {
                        self.networkError()
                    }
                })
            }
        }

        // To-Do: Change constraints programatically so submit button area doesn't cover up Table View
        // tableViewConstraint.firstItem = SafeArea

    }


}

