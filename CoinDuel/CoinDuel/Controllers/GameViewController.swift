//
//  GameViewController.swift
//  CoinDuel
//
//  Created by Henry Wilson on 1/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

import UIKit


class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var gameReturnLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var nextGameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    var game: Game = Game()
    var isGameDisplayMode: Bool = false
    var isPercentReturnMode: Bool = true
    var hasEntry: Bool = false
    var isLateEntry: Bool = false
    let refreshControl = UIRefreshControl()
    let numberFormatter = NumberFormatter()
    var user: User = User(username: UserDefaults.standard.string(forKey: "username")!, coinBalance: 0.0)

    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }
    
    // Completion blocks from https://stackoverflow.com/questions/35357807/running-one-function-after-another-completes
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loading GameView")
        
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
        
        self.startup()
    }
    
    func startup() {
        // Retrieve user balance
        print(self.user.coinBalance)
        self.user.updateCoinBalance() { (completion) -> Void in
            if completion {
                print(self.user.coinBalance)
//                DispatchQueue.main.async() {
//                    self.profileButton.setTitle(self.numberFormatter.string(from: NSNumber(value: user.coinBalance))! + " CC", for: UIControlState .normal)
//                }
                // Retrieve gameId (if we already have it)
                let storedGameId = UserDefaults.standard.string(forKey: "gameId")
                
                // Try and get the current game from the database
                self.game.getCurrentGame() { (success) -> Void in
                    if success {
                        // See if we need to display results
                        if storedGameId != nil && self.game.id != storedGameId {
                            print("Should display results popup")
                            self.game = Game()
                            self.game.id = storedGameId!
                            self.game.getEntry() { (entryStatus) -> Void in
                                if entryStatus == "entry" {
                                    DispatchQueue.main.async() {
                                        self.refreshControl.endRefreshing()
                                        self.loadingActivityIndicatorView.stopAnimating()
                                    }
                                    let storyboard = UIStoryboard(name: "Results", bundle: nil)
                                    let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                                    resultsVC.game = self.game
                                    self.present(resultsVC, animated: true, completion: nil)

                                } else {
                                    // Could not get results for this game
                                    print("No results available")
                                    self.networkError("Could not retrieve game results"
                                    )
                                }
                            }
                        } else {
                            // See if we have an entry
                            self.game.getEntry() { (entryStatus) -> Void in
                                if entryStatus == "entry" {
                                    self.hasEntry = true
                                    // Already has an entry for this game, check if it's started already
                                    if self.game.isActive {
                                        // Update prices
                                        self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
                                            if coinSuccess {
                                                // Store the current game ID (for showing results later)
                                                let defaults = UserDefaults.standard
                                                defaults.set(self.game.id, forKey: "gameId")
                                                
                                                // Show game mode (with prices/returns for coins)
                                                self.displayGameMode()
                                                DispatchQueue.main.async() {
                                                    self.refreshControl.endRefreshing()
                                                    self.loadingActivityIndicatorView.stopAnimating()
                                                }
                                            } else {
                                                self.networkError("Unable to update coin prices")
                                            }
                                        }
                                        // If the game is finished, display the results popup (since we had an entry)
                                    } else if !self.game.isActive && self.game.hasFinished {
                                        self.game = Game()
                                        self.displayNoGameMode()
                                        DispatchQueue.main.async() {
                                            self.refreshControl.endRefreshing()
                                            self.loadingActivityIndicatorView.stopAnimating()
                                        }
                                    } else if !self.game.hasFinished {
                                        // Update prices
                                        self.game.updateCoinPrices() { (coinSuccess) -> Void in
                                            if coinSuccess {
                                                // Show game mode (with prices/returns for coins)
                                                self.displayEntryMode()
                                                DispatchQueue.main.async() {
                                                    self.refreshControl.endRefreshing()
                                                    self.loadingActivityIndicatorView.stopAnimating()
                                                }
                                            } else {
                                                self.networkError("Unable to update coin prices")
                                            }
                                        }
                                    }
                                } else if entryStatus == "none" {
                                    if self.game.hasFinished {
                                        self.game = Game()
                                        self.displayNoGameMode()
                                        DispatchQueue.main.async() {
                                            self.refreshControl.endRefreshing()
                                            self.loadingActivityIndicatorView.stopAnimating()
                                        }
                                        return
                                    } else if self.game.isActive {
                                        self.isLateEntry = true
                                        DispatchQueue.main.async() {
                                            self.refreshControl.endRefreshing()
                                            self.loadingActivityIndicatorView.stopAnimating()
                                        }
                                    }
                                    
                                    // No entry yet, show the entry view
                                    // Update prices
                                    self.game.updateCoinPrices() { (coinSuccess) -> Void in
                                        if coinSuccess {
                                            // Show game mode (with prices/returns for coins)
                                            self.displayEntryMode()
                                            DispatchQueue.main.async() {
                                                self.refreshControl.endRefreshing()
                                                self.loadingActivityIndicatorView.stopAnimating()
                                            }
                                        } else {
                                            self.networkError("Unable to update coin prices")
                                        }
                                    }                        } else {
                                    self.networkError("Could not retrieve entry")
                                }
                            }
                        }
                    } else {
                        self.displayNoGameMode()
                    }
                }
            } else {
                self.displayNoGameMode()
                self.networkError("Could not retrieve user's coin balance")
            }
        }
    }
    
    func displayEntryMode() {
        self.isGameDisplayMode = false

        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false

        gameReturnLabel.isHidden = true
        gameStatusLabel.isHidden = true
        
        self.submitButton.setTitle("Allocate 10 additional CapCoin", for: UIControlState .normal)
        self.submitButton.isEnabled = false
        
        if self.isLateEntry {
            nextGameLabel.text = "Late Entry"
            gameTimeLabel.text = "Game ends " + self.game.finishDate
            self.submitButton.isHidden = false
        } else if !self.hasEntry {
            nextGameLabel.text = "Allocate CapCoin among the cryptos"
            gameTimeLabel.text = "Game starts " + self.game.startDate
            self.submitButton.isHidden = false
        } else {
            nextGameLabel.text = "✓ Entry Submitted"
            gameTimeLabel.text = "Game starts " + self.game.startDate
            self.submitButton.isHidden = true
        }
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    func displayGameMode() {
        self.isGameDisplayMode = true
        
        self.updateGameModeLabels()
        
        gameReturnLabel.isHidden = true
        gameStatusLabel.isHidden = false
        
        nextGameLabel.isHidden = true
        gameTimeLabel.isHidden = false
        self.submitButton.isHidden = true
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    // When there are no active games, display this
    func displayNoGameMode() {
        nextGameLabel.text = "No Games Scheduled"
        gameTimeLabel.text = "Check back soon!"
        
        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false
        gameStatusLabel.isHidden = true
        gameReturnLabel.isHidden = true
        submitButton.isHidden = true
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    func updateGameModeLabels() {
        gameReturnLabel.text = numberFormatter.string(from: NSNumber(value: self.game.totalPercentageReturn()))! + "%"
        
        if (self.game.totalPercentageReturn() > 0) {
            gameStatusLabel.text = "↑ " + numberFormatter.string(from: NSNumber(value: self.game.totalReturn()))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        } else {
            gameStatusLabel.text = "↓ " + numberFormatter.string(from: NSNumber(value: self.game.totalReturn()))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        }
        
        gameTimeLabel.text = "Game ends " + self.game.finishDate
    }
    
    @objc func refreshPriceData(_ sender:Any) {
//        if self.isGameDisplayMode && self.game.isActive {
//            self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
//                if coinSuccess {
//                    // Show price page with returns
//                    DispatchQueue.main.async() {
//                        self.updateGameModeLabels()
//                        self.gameTableView.reloadData()
//                        self.refreshControl.endRefreshing()
//                        self.loadingActivityIndicatorView.stopAnimating()
//                    }
//                } else {
//                    self.networkError("Unable to update coin prices")
//                }
//            }
//        } else {
//            self.refreshControl.endRefreshing()
//            self.loadingActivityIndicatorView.stopAnimating()
//        }
        self.startup()
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
            cell.coinPricePreviewLabel.isHidden = true
            cell.coinPriceLabel.isHidden = false
            cell.coinReturnLabel.isHidden = false

            cell.coinNameLabel.text = coin.ticker
            
            if coin.allocation > 0 {
                cell.coinNameLabel.text = coin.ticker + " (" + String(Int(coin.allocation)) + " CC)"
            }
            
            cell.coinPriceLabel.text = "$" + numberFormatter.string(from: NSNumber(value: coin.currentPrice))!
            
            if self.isPercentReturnMode {
                cell.coinReturnLabel.text = numberFormatter.string(from: NSNumber(value: coin.percentReturn))! + "%"
            } else {
                cell.coinReturnLabel.text = numberFormatter.string(from: NSNumber(value: coin.capCoinReturn))! + " CC"
            }

            if (coin.percentReturn == 0) {
                cell.coinReturnLabel.backgroundColor = Constants.lightGrayColor
            } else if (coin.percentReturn > 0){
                cell.coinReturnLabel.backgroundColor = Constants.greenColor
            } else {
                cell.coinReturnLabel.backgroundColor = Constants.redColor
            }
            
        } else {
            cell.coinAmountStepper.isHidden = false
            cell.coinAmountLabel.isHidden = false
            cell.coinPricePreviewLabel.isHidden = false
            cell.coinPriceLabel.isHidden = true
            cell.coinReturnLabel.isHidden = true
            
            cell.coinAmountStepper.value = coin.allocation
            
            let remaining = 10.0 - self.game.totalAmount()
            if remaining > 0.0 {
                cell.coinAmountStepper.maximumValue = 10.0
                
                self.submitButton.backgroundColor = Constants.orangeColor
                self.submitButton.setTitle("Allocate " + String(Int(remaining)) + " additional CapCoin", for: UIControlState .normal)
                self.submitButton.isEnabled = false
            } else {
                cell.coinAmountStepper.maximumValue = coin.allocation
                
                if self.hasEntry {
                    self.submitButton.setTitle("Update choices", for: UIControlState .normal)
                } else {
                    self.submitButton.setTitle("Submit", for: UIControlState .normal)
                }
                self.submitButton.backgroundColor = Constants.greenColor
                self.submitButton.isEnabled = true
            }
            
            cell.coinNameLabel.text = coin.ticker
            cell.coinAmountLabel.text = String(Int(coin.allocation))
            cell.coinPricePreviewLabel.text = "$" + numberFormatter.string(from: NSNumber(value: coin.currentPrice))!
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "coinDetailSegue", sender: self.tableView(tableView, cellForRowAt: indexPath) as! GameTableViewCell)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultsVC = segue.destination as? ResultsViewController {
            resultsVC.game = self.game
        } else {
            if let segID = segue.identifier {
                if (segID == "coinDetailSegue"){
                    if let indexPath = gameTableView.indexPathForSelectedRow{
                        let coin = self.game.coins[indexPath.row]
                        let storyboard = UIStoryboard(name: "CoinDetail", bundle: nil)
                        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "CoinDetailViewController") as? CoinDetailViewController {
                            destinationVC.coinSymbolLabel = coin.ticker
                            destinationVC.game = self.game
                            destinationVC.currentCoinPrice = coin.currentPrice
                            destinationVC.allocation = coin.allocation.description
                            destinationVC.initialCoinPrice = coin.initialPrice
                            self.present(destinationVC, animated: true, completion: nil)
                            print("showing coinDetail")
                        }
                    }
                }
            }
        }
    }
    
    func networkError(_ errorMessage:String) {
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        let alert = UIAlertController(title: "Uh oh!", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.async() {
            self.refreshControl.endRefreshing()
            self.loadingActivityIndicatorView.stopAnimating()
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("leaving game VC")
        }
    }

    @IBAction func submitButtonPress(_ sender: UIButton) {
        // Submit the entry to the server
        self.game.submitEntry() { (success) -> Void in
            if success {
                self.game.getEntry(completion: { (entryUpdate) in
                    if entryUpdate == "entry" && self.game.isActive {
                        self.hasEntry = true
                        
                        // Update prices
                        self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
                            if coinSuccess {
                                // Store the current game ID (for showing results later)
                                let defaults = UserDefaults.standard
                                defaults.set(self.game.id, forKey: "gameId")
                                
                                // Show price page with returns
                                self.displayGameMode()
                            } else {
                                self.networkError("Unable to update prices")
                            }
                        }
                    } else if entryUpdate == "entry" && !self.game.isActive {
                        self.hasEntry = true
                        // Update prices
                        self.game.updateCoinPrices() { (coinSuccess) -> Void in
                            if coinSuccess {
                                // Show game mode (with prices/returns for coins)
                                self.displayEntryMode()
                            } else {
                                self.networkError("Unable to update coin prices")
                            }
                        }                    } else {
                        self.networkError("Unable to submit entry")
                    }
                })
            }
        }

        // To-Do: Change constraints programatically so submit button area doesn't cover up Table View
        // tableViewConstraint.firstItem = SafeArea

    }
    
    @IBAction func unwindResultsView(unwindSegue: UIStoryboardSegue) {
        print("Unwind")
        UserDefaults.standard.set(nil, forKey: "gameId")
        self.viewDidLoad()
    }

}

