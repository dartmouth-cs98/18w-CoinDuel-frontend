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


class CoinDetailViewController: UIViewController {
    @IBOutlet weak var nameHeaderLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
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

        let apiURL = "https://min-api.cryptocompare.com/data/histohour?fsym=" + coinSymbol + "&tsym=USD&limit=24"

//        source: https://github.com/SwiftyJSON/SwiftyJSON
        Alamofire.request(apiURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json["Data"].arrayValue.count)
                var x = 0
                for coin in json["Data"] {
                    let time = coin.1["time"]
                    let price = Double(coin.1["high"].description)


                    let value = ChartDataEntry(x: Double(x), y: price!) // here we set the X and Y status in a data chart entry

                    self.lineChartEntry.append(value) // here we add it to the data set
                    x = x + 1
                }
                self.updateLineGraph()
            case .failure(let error):
                print(error)
            }
        }
    }

    func updateLineGraph (){
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet

        line1.colors = [NSUIColor.blue] //Sets the colour to blue


        let data = LineChartData() //This is the object that will be added to the chart

        data.addDataSet(line1) //Adds the line to the dataSet


        chartView.data = data //finally - it adds the chart data to the chart and causes an update

        chartView.chartDescription?.text = "My awesome chart" // Here we set the description for the graph

    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            print("going back")
        }

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
//        self.present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
