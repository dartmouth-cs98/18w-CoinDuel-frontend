//
//  CoinDetailViewController.swift
//  CoinDuel
//
//  Created by Rajiv Ramaiah on 2/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//

//Learned to use Charts in swift from : https://github.com/osianSmith/LineChartExample/tree/master


import UIKit
import Charts
import Alamofire
import SwiftyJSON

//the below class was from the demo project from to format line dates https://github.com/danielgindi/Charts
private class CubicLineSampleFillFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return -10
    }
}

class CoinDetailViewController: UIViewController {
    @IBOutlet weak var nameHeaderLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var capCoinAllocationLabel: UILabel!
    @IBOutlet weak var coinPercentChangeLabel: UILabel!
    
    var game: Game = Game()
    var coinSymbolLabel: String = ""
    var currentCoinPrice: Double = 0.0
    var initialCoinPrice: Double = 0.0
    var priceData : [Double] = []
    var lineChartEntry  = [ChartDataEntry]()


    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameHeaderLabel.text = coinSymbolLabel
        coinPriceLabel.text = "$" + currentCoinPrice.description
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.animate(xAxisDuration: 2.5)
        chartView.pinchZoomEnabled = true
        chartView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)

        //        modified xAxis for time line with help from https://github.com/danielgindi/Charts/blob/master/ChartsDemo/Swift/Demos/LineChartTimeViewController.swift
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()

        self.oneDayChart((Any).self)

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


//        round the Double https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
        let x = (currentCoinPrice - initialCoinPrice)/initialCoinPrice * 100
        let percentChange = Double(round(100*x)/100)

        let y = currentCoinPrice - initialCoinPrice
        let totalChange = Double(round(100*y)/100)

        if (totalChange >= 0 && percentChange >= 0){
            self.coinPercentChangeLabel.text = "+" + String(totalChange) + "(" + String(percentChange) + "%)"
        } else{
            self.coinPercentChangeLabel.text = "" + String(totalChange) + "(" + String(percentChange) + "%)"
        }


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


        print(self.game.rawStartDate)

        
        dateFormatter.dateFormat = "EEEE h:mm a z"
        dateFormatter.timeZone = TimeZone.current
        print(dateFormatter.string(from: initialDate!))
        
        // calulate days between dates https://stackoverflow.com/questions/40075850/swift-3-find-number-of-calendar-days-between-two-dates
        let diffInDays = Calendar.current.dateComponents([.day], from: initialDate!, to: currentDate!).day
        // if the game hasn't started yet, display the same graph as daily chart
        if diffInDays! < 0{
            let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=24"
            self.setChartData(apiURL: apiURL, collectPrice: 1)
        } else {
            // if game has started display the hourly data of the coin since start
            let hours = 24 * Int(diffInDays!)
            let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=" + String(hours)
            self.setChartData(apiURL: apiURL, collectPrice: 0)
        }

//        self.setChartData(apiURL: apiURL, collectPrice: 0)
    }

    @IBAction func oneDayChart(_ sender: Any) {
//        api for one days data, 24 hours
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=24"
        self.setChartData(apiURL: apiURL, collectPrice: 1)
    }
    @IBAction func oneWeekChart(_ sender: Any) {
//        api for past 7 days data
        let apiURL = "https://min-api.cryptocompare.com/data/histoday?fsym=" + coinSymbolLabel + "&tsym=USD&limit=7"
        self.setChartData(apiURL: apiURL, collectPrice: 1)

    }
    @IBAction func oneMonthChart(_ sender: Any) {
//        api for past 30 days data
        let apiURL = "https://min-api.cryptocompare.com/data/histoday?fsym=" + coinSymbolLabel + "&tsym=USD&limit=30"
        self.setChartData(apiURL: apiURL, collectPrice: 1)

    }
    @IBAction func oneYearChart(_ sender: Any) {
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbolLabel + "&tsym=USD&limit=24"
        self.setChartData(apiURL: apiURL, collectPrice: 1)
    }

    func setChartData(apiURL: String, collectPrice: Int) -> Void {

        self.lineChartEntry.removeAll()
        //        source: https://github.com/SwiftyJSON/SwiftyJSON
        Alamofire.request(apiURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for coin in json["Data"] {
                    if collectPrice == 1{
                        self.initialCoinPrice = Double(coin.1["high"].description)!
                    }
                    let time = coin.1["time"].description

                    let date = NSDate(timeIntervalSince1970: Double(time)!)

                    let price = Double(coin.1["high"].description)
                    

                    let value = ChartDataEntry(x: Double(time)!, y: price!) // here we set the X and Y status in a data chart entry

                    self.lineChartEntry.append(value) // here we add it to the data set
                }
                self.updateLineGraph()
            case .failure(let error):
                print(error)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
