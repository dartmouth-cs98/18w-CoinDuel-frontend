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
    @IBOutlet weak var gameReturnLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var nextGameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submitIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!


    var game: Game = Game()
    var isGameDisplayMode: Bool = false
    var isPercentReturnMode: Bool = true
    var hasEntry: Bool = false
    var isLateEntry: Bool = false
    let refreshControl = UIRefreshControl()
    let numberFormatter = NumberFormatter()
    var user: User = User(username: UserDefaults.standard.string(forKey: "username")!, coinBalance: 0.0, rank: 0, profilePicture: "profile")

    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
        
        // trade button
        self.tradeButton.layer.masksToBounds = true
        self.tradeButton.layer.cornerRadius = self.tradeButton.frame.height / 2
    }
    
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
        
        // hide submit activity
        self.submitIndicator.isHidden = true
        
        // format text
        self.gameTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        self.startup()
    }
    
    func startup() {
        // Retrieve user balance
        self.user.updateCoinBalance() { (completion) -> Void in
            if completion {
                // Retrieve gameId (if we already have it)
                let storedGameId = UserDefaults.standard.string(forKey: "gameId")
                
                // Try and get the current game from the database
                self.game.getCurrentGame() { (success) -> Void in
                    if success {
                        // See if we need to display results
                        if storedGameId != nil && self.game.id != storedGameId {
                            print("Should display results popup")
                            let resultsGame = Game()
                            resultsGame.id = storedGameId!
                            resultsGame.getEntry() { (entryStatus) -> Void in
                                if entryStatus == "entry" {
                                    DispatchQueue.main.async() {
                                        self.refreshControl.endRefreshing()
                                        self.loadingActivityIndicatorView.stopAnimating()
                                        self.loadingActivityIndicatorView.isHidden = true
                                    }
                                    let storyboard = UIStoryboard(name: "Results", bundle: nil)
                                    let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                                    resultsVC.game = resultsGame
                                    self.present(resultsVC, animated: true, completion: nil)

                                } else {
                                    // Could not get results for this game
                                    print("No results available")
                                    self.networkError("Could not retrieve game results")
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
                                                    self.loadingActivityIndicatorView.isHidden = true
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
                                            self.loadingActivityIndicatorView.isHidden = true
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
                                                    self.loadingActivityIndicatorView.isHidden = true
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
                                            self.loadingActivityIndicatorView.isHidden = true
                                        }
                                        return
                                    } else if self.game.isActive {
                                        self.isLateEntry = true
                                        DispatchQueue.main.async() {
                                            self.refreshControl.endRefreshing()
                                            self.loadingActivityIndicatorView.stopAnimating()
                                            self.loadingActivityIndicatorView.isHidden = true
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
                                                self.loadingActivityIndicatorView.isHidden = true
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
        if(self.submitButton.isHidden){
            self.tableViewBottomConstraint.constant = -30
            self.view.layoutIfNeeded()
        } else {
            self.tableViewBottomConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func displayEntryMode() {
        self.isGameDisplayMode = false
        self.submitIndicator.isHidden = true

        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false

        gameReturnLabel.isHidden = true
        gameStatusLabel.isHidden = true
        
        self.submitButton.setTitle("10 CC AVAILABLE", for: UIControlState .normal)
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
            nextGameLabel.text = "✓ Lineup set"
            gameTimeLabel.text = "Game starts " + self.game.startDate
            self.submitButton.isHidden = true
        }

        if(self.submitButton.isHidden){
            self.tableViewBottomConstraint.constant = -30
            self.view.layoutIfNeeded()
        } else {
            self.tableViewBottomConstraint.constant = 50
            self.view.layoutIfNeeded()
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

        if(self.submitButton.isHidden){
            self.tableViewBottomConstraint.constant = -30
            self.view.layoutIfNeeded()
        } else {
            self.tableViewBottomConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    // When there are no active games, display this
    func displayNoGameMode() {

//        nextGameLabel.text = "No Games Scheduled"
//        gameTimeLabel.text = "Check back soon!"
//
//        nextGameLabel.isHidden = false
//        gameTimeLabel.isHidden = false
//        gameStatusLabel.isHidden = true
//        gameReturnLabel.isHidden = true
//        submitButton.isHidden = true
//
//        DispatchQueue.main.async() {
//            self.gameTableView.reloadData()
//        }
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        // Segue: https://medium.com/@mimicatcodes/create-unwind-segues-in-swift-3-8793f7d23c6f
        // https://stackoverflow.com/questions/32535495/how-to-call-a-function-when-ok-is-pressed-in-an-uialert
        
        // hide spinner
        self.submitIndicator.isHidden = true
        
        let alert = UIAlertController(title: "No Games Scheduled", message: "Please check back later for more games.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.performSegue(withIdentifier: "unwindSeguetoLandingView", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)

        if(self.submitButton.isHidden){
            self.tableViewBottomConstraint.constant = -30
            self.view.layoutIfNeeded()
        } else {
            self.tableViewBottomConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func updateGameModeLabels() {
        gameReturnLabel.text = numberFormatter.string(from: NSNumber(value: self.game.totalPercentageReturn()))! + "%"
        
        if (self.game.totalPercentageReturn() > 0) {
            gameStatusLabel.text = "↑ " + numberFormatter.string(from: NSNumber(value: self.game.totalReturn()))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        } else if (self.game.totalPercentageReturn() < 0) {
            gameStatusLabel.text = "↓ " + numberFormatter.string(from: NSNumber(value: self.game.totalReturn()))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        } else {
            gameStatusLabel.text = "  " + numberFormatter.string(from: NSNumber(value: self.game.totalReturn()))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        }
        
        gameTimeLabel.text = "Game ends " + self.game.finishDate
        
        // hide spinner
        self.submitIndicator.isHidden = true
    }
    
    @objc func refreshPriceData(_ sender:Any) {
        self.loadingActivityIndicatorView.startAnimating()
        self.loadingActivityIndicatorView.isHidden = false
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
        
        // coin amount border radius
        cell.coinAmountLabel.layer.masksToBounds = true
        cell.coinAmountLabel.layer.cornerRadius = cell.coinAmountLabel.frame.height / 2
        
        cell.gameVC = self
        cell.game = game // Give the cell access to the game so it can increment coinAmount
        cell.indexPath = indexPath.row

        // Display varies depending on whether game is active
        
        let coin = self.game.coins[indexPath.row]
        
        // load coin logo
        if (coin.logoUrl == "") {
            coin.getCoinLogo { (success) in
                if (success){
                    
                    // adapted from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
                    let url = URL(string: coin.logoUrl)
                    let image = try? Data(contentsOf: url!)
                    cell.coinLogo.image = UIImage(data: image!)
                    cell.coinLogo.layer.masksToBounds = true
                    cell.coinLogo.layer.cornerRadius = 15
                }
            }
        }
    
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
                self.submitButton.setTitle(String(Int(remaining)) + " CC AVAILABLE", for: UIControlState .normal)
                self.submitButton.isEnabled = false
            } else {
                cell.coinAmountStepper.maximumValue = coin.allocation
                
                if self.hasEntry {
                    self.submitButton.setTitle("UPDATE CHOICES", for: UIControlState .normal)
                } else {
                    self.submitButton.setTitle("SUBMIT", for: UIControlState .normal)
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
            self.loadingActivityIndicatorView.isHidden = true
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        // https://medium.com/@mimicatcodes/create-unwind-segues-in-swift-3-8793f7d23c6f
        performSegue(withIdentifier: "unwindSeguetoLandingView", sender: self)
    }

    @IBAction func submitButtonPress(_ sender: UIButton) {
        // show activity
        self.submitIndicator.isHidden = false
        self.submitButton.isHidden = true
        
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
                                
                                // hide spinner
                                self.submitIndicator.isHidden = true
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
                                
                                // hide spinner
                                self.submitIndicator.isHidden = true
                            }
                        }
                        
                    // entry submission failure
                    } else {
                        self.networkError("Unable to submit entry")
                        self.tableViewBottomConstraint.constant = -30
                        self.view.layoutIfNeeded()
                        self.submitIndicator.isHidden = true
                    }
                })
                
            // submit entry failure
            } else {
                
                // insufficient funds
                if (self.user.coinBalance < 10) {
                    self.submitButton.setTitle("INSUFFICIENT FUNDS", for: UIControlState .normal)
                    self.submitButton.backgroundColor = UIColor.red
                    self.submitIndicator.isHidden = true
                    self.submitButton.isHidden = false
                    self.submitButton.isEnabled = false
                    
                    // display error to user
                    self.networkError("You do not have enough CapCoin available to play in this game.")
                
                // unknown error
                } else {
                    self.networkError("Unable to submit entry")
                    self.tableViewBottomConstraint.constant = -30
                    self.view.layoutIfNeeded()
                    self.submitIndicator.isHidden = true
                }
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

