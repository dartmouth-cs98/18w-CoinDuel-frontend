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
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var nextGameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submitIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var unallocatedCCLabel: UILabel!
    
    var game: Game = Game()
    var isGameDisplayMode: Bool = false
    var isPercentReturnMode: Bool = true
    var hasEntry: Bool = false
    var isLateEntry: Bool = false
    let refreshControl = UIRefreshControl()
    let numberFormatter = NumberFormatter()
    var user: User = User(username: UserDefaults.standard.string(forKey: "username")!, coinBalance: 0.0, rank: 0, profilePicture: "profile")
    
    var SectionHeaderHeight: CGFloat = 40
    let capcoinLimit = 10.0


    //taken from https://stackoverflow.com/questions/664781/change-default-scrolling-behavior-of-uitableview-section-header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let SectionHeaderHeight: CGFloat = 40;
        if (scrollView.contentOffset.y<=SectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=SectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-SectionHeaderHeight, 0, 0, 0);
        }
    }


    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }
    
    // Completion blocks from https://stackoverflow.com/questions/35357807/running-one-function-after-another-completes
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // From https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
        if #available(iOS 10.0, *) {
            refreshControl.tintColor = UIColor.white
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
//        self.gameTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        self.startup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startup()
    }
    
    func startup() {
        self.refreshControl.beginRefreshing()
        
        // Retrieve user balance
        self.user.updateCoinBalance() { (completion) -> Void in
            if completion {
                // Retrieve gameId (if we already have it)
                let storedGameId = UserDefaults.standard.string(forKey: "gameId")
                print("hererererererasdf")
                print(storedGameId)

                // Try and get the current game from the database
                self.game.getCurrentGame() { (success) -> Void in
                    if success {
                        // See if we need to display results
                        print (self.user.lastGameId, self.game.id)
                        if (self.user.lastGameId != "nogame" && self.game.id != self.user.lastGameId) {
                            print("Should display results popup")
                            let resultsGame = Game()
                            resultsGame.id = self.user.lastGameId
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
                                    resultsVC.user = self.user
                                    self.present(resultsVC, animated: true, completion: nil)

                                } else {
                                    // Could not get results for this game
                                    print("No results available")
                                    self.networkError("Could not retrieve game results")
                                    self.user.lastGameId = "nogame"
                                    UserDefaults.standard.set(nil, forKey: "gameId")
                                    self.user.storeGameID(completion: { (success) in
                                        print(success)
                                    })
                                }
                            }
                        } else {
                            // Case 1: Game upcoming
                            if !self.game.isActive {
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
                            } else {
                                // Case 2: Game in progress
                                // Enforce an entry
                                self.game.getEntry() { (entryStatus) -> Void in
                                    if entryStatus != "entry" {
                                        print("submitting empty entry")
                                        self.game.submitEntry() { (success) -> Void in
                                            if success {
                                                self.user.lastGameId = self.game.id
                                                // Store the current game ID (for showing results later)
                                                UserDefaults.standard.set(self.game.id, forKey: "gameId")

                                                self.user.storeGameID(completion: { (success) in
                                                    print(success)
                                                    self.startup()
                                                })
                                            } else {
                                                self.networkError("Unable to submit empty entry")
                                            }
                                        }
                                    } else {
                                        self.hasEntry = true
                                        // Update prices
                                        self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
                                            if coinSuccess {
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
                                    }
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
        self.submitIndicator.isHidden = true
        self.unallocatedCCLabel.isHidden = true

        nextGameLabel.isHidden = false
        gameTimeLabel.isHidden = false

        gameStatusLabel.isHidden = true
        
        nextGameLabel.text = "Game Preview"
        gameTimeLabel.text = "Game starts " + self.game.startDate
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    func displayGameMode() {
        self.isGameDisplayMode = true
        
        self.updateGameModeLabels()
        
        gameStatusLabel.isHidden = false
        
        nextGameLabel.isHidden = true
        gameTimeLabel.isHidden = false
        
        DispatchQueue.main.async() {
            self.gameTableView.reloadData()
        }
    }
    
    // When there are no active games, display this
    func displayNoGameMode() {
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
    }
    
    func updateGameModeLabels() {        
        if (self.game.totalPercentageReturn() > 0) {
            gameStatusLabel.text = "↑ " + numberFormatter.string(from: NSNumber(value: self.game.coinBalance))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        } else if (self.game.totalPercentageReturn() < 0) {
            gameStatusLabel.text = "↓ " + numberFormatter.string(from: NSNumber(value: self.game.coinBalance))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        } else {
            gameStatusLabel.text = "  " + numberFormatter.string(from: NSNumber(value: self.game.coinBalance))! + " CapCoin"
            gameStatusLabel.textColor = UIColor.white
        }
        
        gameTimeLabel.text = "Game ends " + self.game.finishDate
        
        self.unallocatedCCLabel.isHidden = false
        self.unallocatedCCLabel.text = "Available to Invest: " + numberFormatter.string(from: NSNumber(value: self.game.unusedCoinBalance))! + " CC"
        
        // hide spinner
        self.submitIndicator.isHidden = true
    }
    
    @objc func refreshPriceData(_ sender:Any) {
        self.loadingActivityIndicatorView.startAnimating()
        self.loadingActivityIndicatorView.isHidden = true
        self.startup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // From https://medium.com/swift-programming/swift-enums-and-uitableview-sections-1806b74b8138
    func numberOfSections(in tableView: UITableView) -> Int {
        if isGameDisplayMode && self.game.coins.filter({$0.allocation > 0}).count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isGameDisplayMode {
            return self.game.coins.count
        } else {
            if section == 0 && self.game.coins.filter({$0.allocation > 0}).count > 0 {
                return self.game.coins.filter({$0.allocation > 0}).count
            } else if section == 0 {
                return self.game.coins.filter({$0.allocation == 0}).count
            } else {
                return self.game.coins.filter({$0.allocation == 0}).count
            }
        }
    }
    
    // From https://medium.com/swift-programming/swift-enums-and-uitableview-sections-1806b74b8138
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //if section == 0 && isGameDisplayMode && (self.game.coins.filter({$0.allocation > 0}).count > 0) {
        //    return SectionHeaderHeight
        //} else if section == 1 {
        //    return SectionHeaderHeight
        //} else if section == 0 {
        //    return 0
        //}
        return SectionHeaderHeight
    }
    
    // From https://medium.com/swift-programming/swift-enums-and-uitableview-sections-1806b74b8138
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        
        if section == 0 && isGameDisplayMode && (self.game.coins.filter({$0.allocation > 0}).count > 0) {
            label.text = "My Cryptos"
        } else if section == 0 {
            label.text = "Watch List"
        } else if section == 1 {
            label.text = "Watch List"
        }
        
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GameTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
        }
 
        // Display varies depending on whether game is active
        var indexPathRow = indexPath.row
        if indexPath.section == 1 {
            indexPathRow += self.game.coins.filter({$0.allocation > 0}).count
        }
        
        let coin = self.game.coins[indexPathRow]
        
        // load coin logo
        if (coin.logoUrl == "") {
            if let cachedImage = Constants.imageCache.object(forKey: coin.ticker as NSString) {
                cell.coinLogo.image = cachedImage
                cell.coinLogo.layer.masksToBounds = true
                cell.coinLogo.layer.cornerRadius = 15
            } else {
                coin.getCoinLogo { (success) in
                    if (success){
                        
                        // adapted from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
                        let url = URL(string: coin.logoUrl)
                        let image = try? Data(contentsOf: url!)
                        cell.coinLogo.image = UIImage(data: image!)
                        cell.coinLogo.layer.masksToBounds = true
                        cell.coinLogo.layer.cornerRadius = 15
                        Constants.imageCache.setObject(cell.coinLogo.image!, forKey: coin.ticker as NSString)
                    }
                }
            }
        }
    
        if isGameDisplayMode {
            cell.coinPricePreviewLabel.isHidden = true
            cell.coinPriceLabel.isHidden = false
            cell.coinReturnLabel.isHidden = false
            
            cell.coinReturnLabel.layer.masksToBounds = true
            cell.coinReturnLabel.layer.cornerRadius = cell.coinReturnLabel.frame.height / 2

            cell.coinNameLabel.text = coin.ticker
            
            if coin.allocation > 0 {
                cell.coinNameLabel.text = coin.ticker + " (" + numberFormatter.string(from: NSNumber(value: coin.allocation))! + " CC)"
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
            cell.coinPricePreviewLabel.isHidden = false
            cell.coinPriceLabel.isHidden = true
            cell.coinReturnLabel.isHidden = true
            cell.coinNameLabel.text = coin.ticker
            cell.coinPricePreviewLabel.text = "$" + numberFormatter.string(from: NSNumber(value: coin.currentPrice))!
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! GameTableViewCell
//        var tick = cell.coinNameLabel.text
//        var newIndexPath = indexPath
        
        print(indexPath.row)
        print(indexPath.section)
        for coin in self.game.coins {
            print(coin.ticker)
        }
        
        self.performSegue(withIdentifier: "coinDetailSegue", sender: self.tableView(tableView, cellForRowAt: indexPath) as! GameTableViewCell)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultsVC = segue.destination as? ResultsViewController {
            resultsVC.game = self.game
        } else {
            if let segID = segue.identifier {
                if (segID == "coinDetailSegue"){
                    if let indexPath = gameTableView.indexPathForSelectedRow{
                        var indexPathRow = indexPath.row
                        print(indexPath)
                        if (indexPath.section == 1 && self.isGameDisplayMode ){
                            indexPathRow = indexPathRow + self.game.coins.filter({$0.allocation > 0}).count
                            print("New row is")
                            print(indexPathRow)
                        }
                        
                        let coin = self.game.coins[indexPathRow]

                        let storyboard = UIStoryboard(name: "CoinDetail", bundle: nil)
                        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "CoinDetailViewController") as? CoinDetailViewController {
                            destinationVC.coinSymbolLabel = coin.ticker
                            destinationVC.coinIndex = indexPathRow
                            destinationVC.gameId = self.game.id
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

//    @IBAction func submitButtonPress(_ sender: UIButton) {
//        // show activity
//        self.submitIndicator.isHidden = false
//
//        // Submit the entry to the server
//        self.game.submitEntry() { (success) -> Void in
//            if success {
//                self.game.getEntry(completion: { (entryUpdate) in
//                    if entryUpdate == "entry" && self.game.isActive {
//                        self.hasEntry = true
//
//                        // Update prices
//                        self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
//                            if coinSuccess {
//                                // Store the current game ID (for showing results later)
//                                let defaults = UserDefaults.standard
//                                defaults.set(self.game.id, forKey: "gameId")
//
//                                // Show price page with returns
//                                self.displayGameMode()
//                            } else {
//                                self.networkError("Unable to update prices")
//
//                                // hide spinner
//                                self.submitIndicator.isHidden = true
//                            }
//                        }
//                    } else if entryUpdate == "entry" && !self.game.isActive {
//                        self.hasEntry = true
//                        // Update prices
//                        self.game.updateCoinPrices() { (coinSuccess) -> Void in
//                            if coinSuccess {
//                                // Show game mode (with prices/returns for coins)
//                                self.displayEntryMode()
//                            } else {
//                                self.networkError("Unable to update coin prices")
//
//                                // hide spinner
//                                self.submitIndicator.isHidden = true
//                            }
//                        }
//
//                    // entry submission failure
//                    } else {
//                        self.networkError("Unable to submit entry")
//                        self.tableViewBottomConstraint.constant = -30
//                        self.view.layoutIfNeeded()
//                        self.submitIndicator.isHidden = true
//                    }
//                })
//
//            // submit entry failure
//            } else {
//
//                // insufficient funds
//                if (self.user.coinBalance < 10) {
//                    self.submitButton.setTitle("INSUFFICIENT FUNDS", for: UIControlState .normal)
//                    self.submitButton.backgroundColor = UIColor.red
//                    self.submitIndicator.isHidden = true
//                    self.submitButton.isHidden = false
//                    self.submitButton.isEnabled = false
//
//                    // display error to user
//                    self.networkError("You do not have enough CapCoin available to play in this game.")
//
//                // unknown error
//                } else {
//                    self.networkError("Unable to submit entry")
//                    self.tableViewBottomConstraint.constant = -30
//                    self.view.layoutIfNeeded()
//                    self.submitIndicator.isHidden = true
//                }
//            }
//        }
//
//        // To-Do: Change constraints programatically so submit button area doesn't cover up Table View
//        // tableViewConstraint.firstItem = SafeArea
//
//    }
    
    @IBAction func unwindResultsView(unwindSegue: UIStoryboardSegue) {
        print("Unwind")
        self.user.lastGameId = "nogame"
        UserDefaults.standard.set(nil, forKey: "gameId")
        self.user.storeGameID(completion: { (success) in
            print(success)
        })
        self.viewDidLoad()
    }

}

