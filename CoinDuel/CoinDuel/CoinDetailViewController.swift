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

    var game: Game = Game()
    var coinSymbol: String = ""
    var priceData : [Double] = []
    var lineChartEntry  = [ChartDataEntry]()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameHeaderLabel.text = coinSymbol

        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true

//        modified xAxis for time line with help from https://github.com/danielgindi/Charts/blob/master/ChartsDemo/Swift/Demos/LineChartTimeViewController.swift
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()

        self.oneDayChart((Any).self)

    }

    func updateLineGraph (){
        let set1 = LineChartDataSet(values: lineChartEntry, label: coinSymbol) //Here we convert lineChartEntry to a LineChartDataSet

        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1.8
        set1.circleRadius = 4
        set1.setCircleColor(.black)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.fillColor = .white
        set1.fillAlpha = 1
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.fillFormatter = CubicLineSampleFillFormatter()

        set1.colors = [NSUIColor.blue] //Sets the colour to blue
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(set1) //Adds the line to the dataSet
        chartView.data = data //finally - it adds the chart data to the chart and causes an update
        chartView.chartDescription?.text = "My awesome chart" // Here we set the description for the graph

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

    }

    @IBAction func oneDayChart(_ sender: Any) {
//        api for one days data, 24 hours
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbol + "&tsym=USD&limit=24"
        self.setChartData(apiURL: apiURL)
    }
    @IBAction func oneWeekChart(_ sender: Any) {
//        api for past 7 days data
        let apiURL = "https://min-api.cryptocompare.com/data/histoday?fsym=" + coinSymbol + "&tsym=USD&limit=7"
        self.setChartData(apiURL: apiURL)

    }
    @IBAction func oneMonthChart(_ sender: Any) {
//        api for past 30 days data
        let apiURL = "https://min-api.cryptocompare.com/data/histoday?fsym=" + coinSymbol + "&tsym=USD&limit=30"
        self.setChartData(apiURL: apiURL)

    }
    @IBAction func oneYearChart(_ sender: Any) {
        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbol + "&tsym=USD&limit=24"
        self.setChartData(apiURL: apiURL)

    }

    func setChartData(apiURL: String) -> Void {

        self.lineChartEntry.removeAll()
        //        source: https://github.com/SwiftyJSON/SwiftyJSON
        Alamofire.request(apiURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json["Data"].arrayValue.count)
                for coin in json["Data"] {
                    let time = coin.1["time"].description
                    print(time)

                    let date = NSDate(timeIntervalSince1970: Double(time)!)
                    print(date)

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
