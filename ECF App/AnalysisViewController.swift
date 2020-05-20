//
//  AnalysisViewController.swift
//  ECF App
//
//  Created by Bhuvan on 16/02/2020.
//  Copyright © 2020 Bhuvan Belur. All rights reserved.
//

import UIKit
import Charts

class AnalysisViewController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var LineChartView: LineChartView!
    @IBOutlet weak var LabelsStackView: UIStackView!
    
    @IBOutlet weak var firstInfoLabel: UILabel!
    @IBOutlet weak var secondInfoLabel: UILabel!
    
    var myRecords : ([PlayerRecord], [String]) = ([], [])
    var othersRecords : [([PlayerRecord], [String])] = []
    var displayedRecords : [([PlayerRecord], [String])] = []
    
    var meData : ChartData = ChartData()
    var othersData : ChartData = ChartData()
    var chartData : ChartData = ChartData()
    
    var colors : [NSUIColor] = [NSUIColor.red, NSUIColor.blue, NSUIColor.green, NSUIColor.yellow, NSUIColor.purple, NSUIColor.gray, NSUIColor.brown, NSUIColor.cyan, NSUIColor.systemPink, NSUIColor.orange]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Graph settings / aesthetics
        colors = colors + colors + colors
        LineChartView.xAxis.labelPosition = .bottom
        LineChartView.xAxis.drawGridLinesEnabled = false
        LineChartView.rightAxis.enabled = false
        LineChartView.leftAxis.drawGridLinesEnabled = false
        LineChartView.leftAxis.drawGridLinesEnabled = true
        LineChartView.pinchZoomEnabled = false
        LineChartView.doubleTapToZoomEnabled = false
        LineChartView.leftAxis.axisMinimum = 0
        LineChartView.isUserInteractionEnabled = false
        
        // Adjust the chart's legend to be adaptative to system color changes (if these exist)
        if #available(iOS 13.0, *) {
            LineChartView.legend.textColor = .label
        }
        if #available(iOS 13.0, *) {
            LineChartView.xAxis.labelTextColor = .label
        }
        if #available(iOS 13.0, *) {
            LineChartView.leftAxis.labelTextColor = .label
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if segment.selectedSegmentIndex == 0 {
            showMeGraph()
        }
        else {
            showOthersGraph()
        }
    }
    
    // Callback for me/others segment control
    @IBAction func segmentChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            showMeGraph()
        }
        else {
            showOthersGraph()
        }
    }
    
    // Fetches needed data for the about to be displayed graph, and updates class variables with this data
    // Also creates formats chartData, which can be used for updating the graph
    func createGraph(me : Bool) {
        
        // Reset/set class variables
        displayedRecords = []
        othersRecords = []
        chartData = LineChartData();
        displayedRecords.append(getRecords(referenceCode: playerReference))
        myRecords = displayedRecords[0]
        
        if !me {
            if (UserDefaults.standard.object(forKey: "peers") as! [String]).count != 0 {
                for i in 0...(UserDefaults.standard.object(forKey: "peers") as! [String]).count-1 {
                    if (UserDefaults.standard.object(forKey: "peers") as! [String])[i] != playerReference {
                        displayedRecords.append(getRecords(referenceCode: (UserDefaults.standard.object(forKey: "peers") as! [String])[i]))
                    }
                }
            }
        }
        othersRecords = displayedRecords
        othersRecords.remove(at: 0)
        
        let formatter = ChartXAxisFormatter()
        var x = 0
        for j in displayedRecords {
            var entries = [ChartDataEntry]()
            
            // Add every point to a ChartDataEntry
            for i in 0...j.0.count-1 {
                var yval : Double = Double()
                if typeSegment.selectedSegmentIndex == 0 {
                    yval = Double(Int(j.0[i].currentStandard))
                }
                else {
                    yval = Double(Int(j.0[i].currentRapid))
                }
                
                let month = Int(j.1[i].prefix(2))!
                
                let year = Int(j.1[i].suffix(2))!
                let xval = Double((year*12)+month)
                let entry = ChartDataEntry(x: xval, y: yval)
                entries.append(entry)
            }
            
            // Put all the data points into a DataSet
            var set = LineChartDataSet()
            if #available(iOS 13.0, *) {
                set.valueTextColor = .label
            }
            
            entries.sort(by: {$0.x < $1.x})
            
            // Show set as "you" if it is you
            if x == 0 {
                set = LineChartDataSet(entries: entries, label:"You")
            }
            else {
                set = LineChartDataSet(entries: entries, label:j.0[0].name)
            }
            
            if #available(iOS 13.0, *) {
                set.valueTextColor = .label
            }
            
            // Aesthetics
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            let Nformatter = DefaultValueFormatter(formatter: numberFormatter)
            chartData.setValueFormatter(Nformatter)

            let gradientColors = [UIColor.green.cgColor, UIColor.red.cgColor] as CFArray
            let colorLocations:[CGFloat] = [1.0, 0.0]
            let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
            set.fill = Fill.fillWithLinearGradient(gradient!, angle:90.0)
            
            set.drawFilledEnabled = true
            set.mode = .cubicBezier
            set.cubicIntensity = 0.05
            set.setCircleColor(colors[x])
            set.setColor(colors[x])
            set.circleRadius = 5
            
            chartData.addDataSet(set)
            
            x += 1
        }
        LineChartView.xAxis.valueFormatter = formatter
    }
    
    // Update display to show graph with others comparison
    func showOthersGraph() {
        // Fetch data needed for stat calculations, updating class variables
        createGraph(me: false)
        
        LineChartView.data = chartData
        LineChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInSine)
        
        var increasesCount = 0
        var totalIncrease = 0
        var averageIncrease = 0.0
        
        var othersIncreasesCount = 0
        var othersTotalIncrease = 0
        var othersAverageIncrease = 0.0
        
        // calculate analysis stats based on whether standard or rapid is selected
        // TODO change this to use closures to eliminate the if ... else
        if typeSegment.selectedSegmentIndex == 0 {
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard) != 0 {
                    totalIncrease += (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard)
                    increasesCount += 1
                }
            }
            for j in othersRecords {
                for i in 1...j.0.count-1 {
                    if (j.0[i].currentStandard-j.0[i-1].currentStandard) != 0 {
                        othersTotalIncrease += (j.0[i].currentStandard-j.0[i-1].currentStandard)
                        othersIncreasesCount += 1
                    }
                }
            }
        }
        else {
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid) != 0 {
                    totalIncrease += (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid)
                    increasesCount += 1
                }
            }
            for j in othersRecords {
                for i in 1...j.0.count-1 {
                    if (j.0[i].currentRapid-j.0[i-1].currentRapid) != 0 {
                        othersTotalIncrease += (j.0[i].currentRapid-j.0[i-1].currentRapid)
                        othersIncreasesCount += 1
                    }
                }
            }
        }
        
        // Actually use the calculated stats
        if increasesCount != 0 {
            averageIncrease = round((Double(totalIncrease) / Double(increasesCount))*10)/10
            
            firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
        }
        else {
            firstInfoLabel.text = ""
        }
        
        if othersIncreasesCount != 0 {
            othersAverageIncrease = round((Double(othersTotalIncrease) / Double(othersIncreasesCount))*10)/10
            secondInfoLabel.text = "Everyone else increased by an average \(othersAverageIncrease) points every round."
        }
        else {
            secondInfoLabel.text = ""
        }
    }
    
    // Displays the graph and stats for self comparison
    func showMeGraph() {
        // fetch data, updating class variables with it
        createGraph(me: true)
        LineChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInSine)
        LineChartView.data = chartData;
        
        var increasesCount = 0
        var totalIncrease = 0
        var maxScore = 0;
        var minScore = 0 ;
        
        // calculate analysis stats based on whether standard or rapid is selected
        // TODO change this to use closures to eliminate the if ... else
        if typeSegment.selectedSegmentIndex == 0 {
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard) != 0 {
                    totalIncrease += (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard)
                    increasesCount += 1
                }
            }
            
            myRecords.0.sort { (a, b) -> Bool in
                return a.currentStandard > b.currentStandard
            }
            maxScore = myRecords.0.last!.currentStandard
            minScore = myRecords.0.first!.currentStandard
        }
        else {
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid) != 0 {
                    totalIncrease += (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid)
                    increasesCount += 1
                }
            }
            
            myRecords.0.sort { (a, b) -> Bool in
                return a.currentRapid > b.currentRapid
            }
            maxScore = myRecords.0.last!.currentRapid
            minScore = myRecords.0.first!.currentRapid
        }
        
        // Display the calculated stats
        if increasesCount != 0 {
            let averageIncrease = round(Double(totalIncrease) / Double(increasesCount))
            firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
        }
        else {
            firstInfoLabel.text = ""
        }
        secondInfoLabel.text = "Your highest and lowest scores are \(maxScore) and \(minScore)."
    }
    
    // Callback for me/others segment control
    @IBAction func typeSegmentChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            showMeGraph()
        }
        else {
            showOthersGraph()
        }
    }
}

