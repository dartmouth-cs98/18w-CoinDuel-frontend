//
//  CoinDetailViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

//Learned to use Charts in swift from : https://github.com/osianSmith/LineChartExample/tree/master


import UIKit
import GMStepper

import Charts
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

//the below class was from the demo project from to format line dates https://github.com/danielgindi/Charts
private class CubicLineSampleFillFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return -10
    }
}

class CoinDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var nameHeaderLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurBackgroundView: UIView!
    @IBOutlet var popOverView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var activeChartButtons: UIStackView!
    @IBOutlet weak var capCoinAllocationLabel: UILabel!
    @IBOutlet weak var coinPercentChangeLabel: UILabel!
    @IBOutlet weak var inactiveChartButtons: UIStackView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var availableCCLabel: UILabel!
    @IBOutlet weak var buySellControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tradePriceLabel: UILabel!
    @IBOutlet weak var currentHoldingsLabel: UILabel!
    
    @IBOutlet weak var tradeAvailableCCLabel: UILabel!
    @IBOutlet weak var tradeBottomView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var allocationAbilityLabel: UILabel!

    @IBOutlet weak var tradeErrorLabel: UILabel!

    @IBOutlet weak var tradeStepper: GMStepper!
    @IBOutlet weak var coinDescription: UILabel!
    
    var game: Game = Game()
    var gameId: String = ""
    var coinSymbolLabel: String = ""
    var currentCoinPrice: Double = 0.0
    var coinIndex: Int = 0
    var allocation: Double = 0.0
    var initialCoinPrice: Double = Double()
    var tempInitialPrice: Double = 0.0
    var priceData : [Double] = []
    var newsHeaders = [String]()
    var newsDates = [String]()
    var newsUrls = [String]()
    var lineChartEntry  = [ChartDataEntry]()
    var granularity = 20000
    var currentTimeFrame = 0
    var user: User = User(username: UserDefaults.standard.string(forKey: "username")!, coinBalance: 0.0, rank: 0, profilePicture: "profile")
    var isTradeViewEnabled = false
    let numberFormatter = NumberFormatter()


    override func viewDidLayoutSubviews(){
        self.backgroundImageView.applyGradient(colours: [UIColor(red:0.43, green:0.29, blue:0.63, alpha:1.0), UIColor(red:0.18, green:0.47, blue:0.75, alpha:1.0)])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Stepper styling, see here https://cocoapods.org/pods/GMStepper

        // Button styling
        self.buyButton.layer.masksToBounds = true
        self.buyButton.layer.cornerRadius = 15
        self.buyButton.alpha = 1.0
        
        // Retrieve news
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        // Number format
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        // Start with labels hidden
        self.nameHeaderLabel.isHidden = true
        self.coinPriceLabel.isHidden = true
        self.coinPercentChangeLabel.isHidden = true
        
        // Bottom trading area
        self.allocationAbilityLabel.text = ""
        self.availableCCLabel.text = ""
        
        self.startup()

        self.buyButton.isEnabled = true
        
        self.amountTextField.becomeFirstResponder()
        self.amountTextField.delegate = self

        //round popover edges
        self.popOverView.layer.masksToBounds = true
        self.popOverView.layer.cornerRadius = 10
    }

    
    func chart() {
        self.nameHeaderLabel.isHidden = false
        self.coinPriceLabel.isHidden = false
        self.coinPercentChangeLabel.isHidden = false
        
        // chart setup
        self.activeChartButtons.isHidden = false
        self.inactiveChartButtons.isHidden = true
        
        //        setup chart and call it for one day values
        self.oneDayChart((Any).self)
        
        let apiUrl = Constants.API + "coin/" + coinSymbolLabel
        Alamofire.request(apiUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let newsArray = json["articles"].arrayValue
                self.coinDescription.text = json["description"].stringValue
//                self.webViewForInfo.loadHTMLString(json["description"].stringValue, baseURL: nil)
                self.coinName.text = json["name"].stringValue + " News"
                self.nameHeaderLabel.text = json["name"].stringValue
                for i in 0 ..< newsArray.count {
                    self.newsHeaders.append(newsArray[i]["title"].stringValue)
                    self.newsDates.append(newsArray[i]["published_on"].stringValue)
                    self.newsUrls.append(newsArray[i]["url"].stringValue)
                }
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startup() {
        // Retrieve user balance
        self.user.updateCoinBalance() { (completion) -> Void in
            if completion {
                // Try and get the current game from the database
                self.game.getCurrentGame() { (success) -> Void in
                    if success {
                        // See if we need to display results
                        if self.game.id != self.gameId {
                            print("Should display results popup")
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            // Case 1: Game upcoming
                            if !self.game.isActive {
                                // Update prices
                                self.game.updateCoinPrices() { (coinSuccess) -> Void in
                                    if coinSuccess {
                                        // Show game mode (with prices/returns for coins)
                                        for coin in self.game.coins {
                                            if coin.ticker == self.coinSymbolLabel {
                                                self.currentCoinPrice = coin.currentPrice
                                                self.allocation = coin.allocation
                                                self.initialCoinPrice = coin.initialPrice
                                            }
                                        }
                                        self.activeChartButtons.isHidden = true
                                        self.inactiveChartButtons.isHidden = false
                                        self.coinPercentChangeLabel.text = ""
                                        self.coinPriceLabel.text = "$" + self.currentCoinPrice.description
                                        self.buyButton.isEnabled = false
                                        self.buyButton.alpha = 0.3
                                        self.allocationAbilityLabel.text = "Trading Closed"
                                        self.availableCCLabel.text = "Game preview mode"
                                        self.chart()
                                    } else {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            } else {
                                // Case 2: Game in progress
                                // Enforce an entry
                                self.game.getEntry() { (entryStatus) -> Void in
                                    if entryStatus != "entry" {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    // Update prices
                                    self.game.updateCoinPricesAndReturns() { (coinSuccess) -> Void in
                                        if coinSuccess {
                                            // Show game mode (with prices/returns for coins)
                                            for coin in self.game.coins {
                                                if coin.ticker == self.coinSymbolLabel {
                                                    self.currentCoinPrice = coin.currentPrice
                                                    self.allocation = coin.allocation
                                                    self.initialCoinPrice = coin.initialPrice
                                                }
                                            }
                                            
                                            if self.allocation > 0.0 {
                                                self.capCoinAllocationLabel.text = self.numberFormatter.string(from: NSNumber(value: self.allocation))! + " CC"
                                            } else {
                                                self.capCoinAllocationLabel.text = ""
                                            }
                                            self.coinPercentChangeLabel.text = ""
                                            self.coinPriceLabel.text = "$" + self.currentCoinPrice.description
                                            
                                            self.availableCCLabel.text = self.numberFormatter.string(from: NSNumber(value: self.game.unusedCoinBalance))! + " CC"
                                            self.allocationAbilityLabel.text = "Available CapCoin"
                                            self.buyButton.isEnabled = true
                                            self.buyButton.alpha = 1.0
                                            self.chart()
                                        } else {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NewsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of NewsTableViewCell.")
        }
        
        cell.articleTitle.text = newsHeaders[indexPath.row]
        let date = NSDate(timeIntervalSince1970: Double(newsDates[indexPath.row])!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd, YYYY hh:mm a"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        cell.articleDate.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.openURL(URL(string: newsUrls[indexPath.row])!)
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("going back")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func currentGameChart(_ sender: Any) {
        // Get the date (https://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate)


        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let initialDate = dateFormatter.date(from: self.game.rawStartDate)
        let currentDate = dateFormatter.date(from: Date().description)
        
        // calulate days between dates https://stackoverflow.com/questions/40075850/swift-3-find-number-of-calendar-days-between-two-dates

        let time = currentDate!.timeIntervalSince(initialDate!)
        let hours = time/3600

        // if the game hasn't started yet, display the same graph as daily chart
        if hours < 24 {
            if(self.game.isActive){
                let minutes = Int(hours*60)
                let apiURL = "https://min-api.cryptocompare.com/data/histominute?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + minutes.description
                self.setChartData(apiURL: apiURL, collectPrice: 1)
            }
        } else {
            let minutes = Int(hours*60)
            // if game has started display the hourly data of the coin since start
            let apiURL = "https://min-api.cryptocompare.com/data/histominute?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + minutes.description
            self.tempInitialPrice = self.initialCoinPrice
            self.setChartData(apiURL: apiURL, collectPrice: 1)
        }

//        self.setChartData(apiURL: apiURL, collectPrice: 0)
    }

    @IBAction func oneDayChart(_ sender: Any) {
//        api for one days data, 24 hours
        let mins = 24 * 60
        let apiURL = "https://min-api.cryptocompare.com/data/histominute?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + mins.description
        self.setChartData(apiURL: apiURL, collectPrice: 1)
        self.granularity = 20000
        self.currentTimeFrame = 0
    }
    @IBAction func oneWeekChart(_ sender: Any) {
//        api for past 7 days data
        let hours = 7 * 24
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + hours.description
        self.setChartData(apiURL: apiURL, collectPrice: 1)
        self.granularity = 20000 * 7
        self.currentTimeFrame = 1

    }
    @IBAction func oneMonthChart(_ sender: Any) {
//        api for past 30 days data
        let hours = 30 * 24
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + hours.description
        self.setChartData(apiURL: apiURL, collectPrice: 1)
        self.granularity = 20000 * 25
        self.currentTimeFrame = 2

    }
    @IBAction func oneYearChart(_ sender: Any) {
        let apiURL = "https://min-api.cryptocompare.com/data/histoday?fsym=" + coinSymbolLabel + "&tsym=USD&limit=365"
        self.setChartData(apiURL: apiURL, collectPrice: 1)
        self.granularity = 20000 * 285
        self.currentTimeFrame = 3
    }

    func setChartData(apiURL: String, collectPrice: Int) -> Void {

        self.lineChartEntry.removeAll()
        //        source: https://github.com/SwiftyJSON/SwiftyJSON
        Alamofire.request(apiURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var toggler = collectPrice
                for coin in json["Data"] {
                    if toggler == 1{
                        self.tempInitialPrice = Double(coin.1["high"].description)!
                        toggler = 0
                    }
                    let time = coin.1["time"].description
                    let price = Double(coin.1["high"].description)
                    

                    let value = ChartDataEntry(x: Double(time)!, y: price!) // here we set the X and Y status in a data chart entry

                    self.lineChartEntry.append(value) // here we add it to the data set
                }
                self.setChartParameters()
                self.updateLineGraph()
            case .failure(let error):
                print(error)
            }
        }
    }

    // draws graph with data
    func updateLineGraph (){
        let set1 = LineChartDataSet(values: lineChartEntry, label: coinSymbolLabel) //Here we convert lineChartEntry to a LineChartDataSet

        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1
        set1.circleRadius = 4
        set1.setColor(.black)
        set1.setCircleColor(.black)
        set1.highlightColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        set1.fillColor = .white
        set1.fillAlpha = 1
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.fillFormatter = CubicLineSampleFillFormatter()
        set1.drawValuesEnabled = false

        let data = LineChartData() //This is the object that will be added to the chart
        data.setValueTextColor(.red)

        data.addDataSet(set1) //Adds the line to the dataSet
        //finally - it adds the chart data to the chart and causes an update
        chartView.data = data
        chartView.legend.enabled = false
        // removes horizontal lines from chart
        let leftAxis:YAxis = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelFont = UIFont.init(name: "AvenirNext-Regular", size: 11)!

        //        round the Double https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
        let x = ((currentCoinPrice - tempInitialPrice)/tempInitialPrice) * 100
        let percentChange = Double(round(100*x)/100)
        print(tempInitialPrice, currentCoinPrice)

        let y = currentCoinPrice - tempInitialPrice
        let totalChange = Double(round(100*y)/100)

        if (totalChange >= 0 && percentChange >= 0){
            self.coinPercentChangeLabel.textColor = Constants.greenColor
            self.coinPercentChangeLabel.text = "+" + String(totalChange) + " (" + String(percentChange) + "%)"
        } else{
            self.coinPercentChangeLabel.textColor = Constants.redColor
            self.coinPercentChangeLabel.text = "" + String(totalChange) + " (" + String(percentChange) + "%)"
        }

        self.chartView.animate(xAxisDuration: 2)

    }

    func setChartParameters(){
        // Set all chart attributes
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        //        chartView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)

        //        modified xAxis for time line with help from https://github.com/danielgindi/Charts/blob/master/ChartsDemo/Swift/Demos/LineChartTimeViewController.swift
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = Double(self.granularity)
        xAxis.valueFormatter = DateValueFormatter(rank: currentTimeFrame)

        let rightYAxis = chartView.rightAxis
        rightYAxis.drawGridLinesEnabled = false
        rightYAxis.drawLabelsEnabled = false
        rightYAxis.drawAxisLineEnabled = false

        let leftYAxis = chartView.leftAxis
        leftYAxis.drawGridLinesEnabled = true
        leftYAxis.drawLabelsEnabled = true
        leftYAxis.drawAxisLineEnabled = true
        leftYAxis.labelFont = .systemFont(ofSize: 14)
    }

    @IBAction func gameButtonPressed(_ sender: UIButton) {
        let activeChartButtons = self.activeChartButtons.arrangedSubviews
        for button in activeChartButtons {
            button.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha: 1.0)
        }
        let inactiveChartButtons = self.inactiveChartButtons.arrangedSubviews
        for button in inactiveChartButtons {
            button.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha: 1.0)
        }
        sender.backgroundColor = UIColor.gray
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }

    @IBAction func buyButtonPressed(_ sender: Any) {
        self.presentTradeView(orderType: "buy")
    }

    func presentTradeView(orderType: String) {
        //make background faded out.
        self.tradePriceLabel.text = self.coinPriceLabel.text
        self.currentHoldingsLabel.text = numberFormatter.string(from: NSNumber(value: self.game.coins[coinIndex].allocation))! + " CC"
        self.tradeAvailableCCLabel.text = numberFormatter.string(from: NSNumber(value: self.game.unusedCoinBalance))! + " CC"

        self.view.bringSubview(toFront: self.blurBackgroundView)
        self.blurBackgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)

        self.view.addSubview(self.popOverView)
        self.popOverView.center = self.view.center


        self.popOverView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.popOverView.alpha = 0.0;
        UIView.animate(withDuration: 0.50, animations: {
            self.popOverView.alpha = 1.0
            self.popOverView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
        self.isTradeViewEnabled = true
    }

    @IBAction func leaveTradeButtonPressed(_ sender: Any) {
        self.dismissPopup()
    }

    @IBAction func placeOrderPressed(_ sender: Any) {
//        let requestedAmount = self.amountTextField.value
//        if (self.tradeStepper.value <= self.game.unusedCoinBalance){
//            self.game.coins[coinIndex].allocation = self.tradeStepper.value
//            //add activity indicator of some sort
//            self.game.submitEntry(completion: { (result) in
//                if (result){
//                    print("success")
//                } else{
//                    print("submission error")
//                }
//            })
//        }
        
        print(self.game.coins)

        var requestedAmount = Double(self.amountTextField.text!)
        if requestedAmount != nil {
            print(self.buySellControl.description)
            var requestedAmountRounded = round(100.0 * requestedAmount!) / 100.0
            
            if self.buySellControl.selectedSegmentIndex == 1 {
                print("sell order")
                requestedAmountRounded *= -1.0
            }
            print(requestedAmountRounded)
            print(self.game.coins[self.coinIndex].allocation)
            var oldAllocation = self.game.coins[self.coinIndex].allocation
            self.game.coins[self.coinIndex].allocation += requestedAmountRounded

            if (self.game.coins[self.coinIndex].allocation < 0 || requestedAmountRounded == 0){
                self.errorMessage("You do not have enough CC in this position to sell " + requestedAmount!.description + "CC")
                self.game.coins[self.coinIndex].allocation = oldAllocation
            } else {
                //add activity indicator of some sort
                self.game.submitEntry(completion: { (result) in
                    if (result){
                        print("success")
                        var msg = "Successfully "
                        if self.buySellControl.selectedSegmentIndex == 0 {
                            msg += "bought "
                        } else {
                            msg += "sold "
                        }
                        msg += self.game.coins[self.coinIndex].ticker
                        requestedAmount = 0
                        self.successMessage(msg)
                    } else{
                        print()
                        print("submission error")
                    }
                })
            }
        }
//        let roundedRequestedAmount = requestedAmount
//        print(requestedAmount)
//        if requestedAmount =  {
//            print("Got here")
//        }
        
    }
    
    @IBAction func editingChanged(_ sender: Any) {
    }
    
    
    // https://www.markusbodner.com/2017/06/20/how-to-verify-and-limit-decimal-number-inputs-in-ios-with-swift/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return replacementText.isValidDouble(maxDecimalPlaces: 2)
    }
    
    func successMessage(_ msg:String) {
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        let alert = UIAlertController(title: "Order Filled", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.dismissPopup()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    func errorMessage(_ msg:String) {
        // from: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift

        let alert = UIAlertController(title: "Order Failed", message: msg, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.dismissPopup()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.20, animations: {
            self.popOverView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.popOverView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.popOverView.removeFromSuperview()
                self.startup()
            }
        });
        self.view.sendSubview(toBack: self.blurBackgroundView)
        self.isTradeViewEnabled = false
    }
    

}
