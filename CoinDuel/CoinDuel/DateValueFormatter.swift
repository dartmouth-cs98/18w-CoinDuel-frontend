//
//  DateValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//
//Got this class from https://github.com/danielgindi/Charts

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    var rank: Int
    
    init(rank: Int) {
        self.rank = rank

        super.init()
        if (rank == 0) {
            dateFormatter.dateFormat = "hh:mm a"
        }
        else if (rank == 1) {
            dateFormatter.dateFormat = "EEE"
        }
        else if (rank == 2) {
            dateFormatter.dateFormat = "MM/dd"
        }
        else if (rank == 3) {
            dateFormatter.dateFormat = "MM/dd"
        }
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

