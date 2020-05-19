//
//  ChartXAxisFormatter.swift
//  ECF App
//
//  Created by Bhuvan on 16/02/2020.
//  Copyright © 2020 Bhuvan Belur. All rights reserved.
//

import UIKit
import Charts

class ChartXAxisFormatter: IAxisValueFormatter {
    
    // Format date into an nice readable string
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let year = floor(value/12)
        let month = ((value/12)-year)*12
        return String(Int(month)) + "/" + String(Int(year))
    }
}
