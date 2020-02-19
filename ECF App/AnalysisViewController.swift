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
    
    var meData : ChartData = ChartData()
    var othersData : ChartData = ChartData()
    
    var colors : [NSUIColor] = [NSUIColor.red, NSUIColor.blue, NSUIColor.black, NSUIColor.green, NSUIColor.yellow, NSUIColor.purple, NSUIColor.gray, NSUIColor.brown, NSUIColor.cyan, NSUIColor.systemPink, NSUIColor.orange]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colors = colors + colors + colors
        // Do any additional setup after loading the view.
        LineChartView.xAxis.labelPosition = .bottom
        LineChartView.xAxis.drawGridLinesEnabled = false
        LineChartView.rightAxis.enabled = false
        LineChartView.leftAxis.drawGridLinesEnabled = false
        LineChartView.leftAxis.drawGridLinesEnabled = true
        LineChartView.pinchZoomEnabled = false
        LineChartView.doubleTapToZoomEnabled = false
        LineChartView.leftAxis.axisMinimum = 0
        LineChartView.zoomOut()

        
        if #available(iOS 13.0, *) {
            LineChartView.legend.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            LineChartView.xAxis.labelTextColor = .label
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            LineChartView.leftAxis.labelTextColor = .label
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateMeData()
        updateOthersGraph()
        if segment.selectedSegmentIndex == 0 {
            showMeGraph()
        }
        else {
            showOthersGraph()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func segmentChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            showMeGraph()
        }
        else {
            showOthersGraph()
        }
        print(segment.selectedSegmentIndex)
    }
    
    func updateMeData() {
        
        myRecords = getRecords(referenceCode: playerReference)
        
        meData = ChartData()
        
        let formatter = ChartXAxisFormatter()
        var entries = [ChartDataEntry]()
        
        for i in 0...myRecords.0.count-1 {
            var yval : Double = Double()
            if typeSegment.selectedSegmentIndex == 0 {
                yval = Double(Int(myRecords.0[i].currentStandard))
            }
            else {
                yval = Double(Int(myRecords.0[i].currentRapid))
            }
            
            let month = Int(myRecords.1[i].prefix(2))!
            
            let year = Int(myRecords.1[i].suffix(2))!
            let xval = Double((year*12)+month)

            let entry = ChartDataEntry(x: xval, y: yval)
            entries.append(entry)
        }

        entries.sort(by: {$0.x < $1.x})
        let set = LineChartDataSet(entries: entries, label:"You")
        if #available(iOS 13.0, *) {
            set.valueTextColor = .label
        } else {
            // Fallback on earlier versions
        }
        meData = LineChartData(dataSet: set)
        

        let gradientColors = [UIColor.green.cgColor, UIColor.red.cgColor] as CFArray
        let colorLocations:[CGFloat] = [1.0, 0.0]
        
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        
        set.fill = Fill.fillWithLinearGradient(gradient!, angle:90.0)
        set.drawFilledEnabled = true
        set.mode = .cubicBezier
        set.cubicIntensity = 0.05
        LineChartView.xAxis.valueFormatter = formatter
        set.circleRadius = 5
        
    }
    
    func updateOthersGraph() {
        othersRecords = []
        othersData = LineChartData()
        myRecords = getRecords(referenceCode: playerReference)
    
        othersRecords.append(myRecords)
        if (UserDefaults.standard.object(forKey: "peers") as! [String]).count != 0 {
            for i in 0...(UserDefaults.standard.object(forKey: "peers") as! [String]).count-1 {
                if (UserDefaults.standard.object(forKey: "peers") as! [String])[i] != playerReference {
                    othersRecords.append(getRecords(referenceCode: (UserDefaults.standard.object(forKey: "peers") as! [String])[i]))
                }
                
            }
        }
        
        
        
        let formatter = ChartXAxisFormatter()
        var x = 0
        for j in othersRecords {
            var entries = [ChartDataEntry]()
            
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
                print(j.0[i].currentStandard)
                let entry = ChartDataEntry(x: xval, y: yval)
                entries.append(entry)
            }
            
            var set = LineChartDataSet()
            if #available(iOS 13.0, *) {
                set.valueTextColor = .label
            } else {
                // Fallback on earlier versions
            }
            entries.sort(by: {$0.x < $1.x})

            if x == 0 {
                set = LineChartDataSet(entries: entries, label:"You")
            }
            else {
                set = LineChartDataSet(entries: entries, label:j.0[0].name)
            }
            if #available(iOS 13.0, *) {
                set.valueTextColor = .label
            } else {
                // Fallback on earlier versions
            }
            othersData.addDataSet(set)
            

            
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

            x += 1
        }
        
        LineChartView.xAxis.valueFormatter = formatter
    }
    
    func showOthersGraph() {
        updateOthersGraph()
        print(othersData.dataSets[0])
        LineChartView.data = othersData
        LineChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInSine)
        
        if typeSegment.selectedSegmentIndex == 0 {
            var increasesCount = 0
            var totalIncrease = 0
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard) != 0 {
                    totalIncrease += (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard)
                    increasesCount += 1
                    
                }
                if i == 1 && myRecords.0[i-1].currentStandard != 0 {
                    totalIncrease += myRecords.0[i-1].currentStandard
                    increasesCount += 1
                }
            }
            var averageIncrease = 0
            if increasesCount != 0{
                averageIncrease = totalIncrease/increasesCount
                firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
            }
            else {
                firstInfoLabel.text = ""
            }
            
            
            
            increasesCount = 0
            totalIncrease = 0
            var newOthers = othersRecords
            newOthers.remove(at: 0)
            
            for j in newOthers {
                for i in 1...j.0.count-1 {
                    if (j.0[i].currentStandard-j.0[i-1].currentStandard) != 0 {
                        totalIncrease += (j.0[i].currentStandard-j.0[i-1].currentStandard)
                        increasesCount += 1
                        
                    }
                    if i == 1 && j.0[i-1].currentStandard != 0 {
                        totalIncrease += j.0[i-1].currentStandard
                        increasesCount += 1
                    }
                }
            }
            
            if increasesCount != 0 {
                averageIncrease = totalIncrease/increasesCount
                secondInfoLabel.text = "Everyone else increased by an average \(averageIncrease) points every round."
            }
            else {
                secondInfoLabel.text = ""
            }
            
        }
        else {
            var increasesCount = 0
            var totalIncrease = 0
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid) != 0 {
                    totalIncrease += (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid)
                    increasesCount += 1
                    
                }
                if i == 1 && myRecords.0[i-1].currentRapid != 0 {
                    totalIncrease += myRecords.0[i-1].currentRapid
                    increasesCount += 1
                }
            }
            
            var averageIncrease = 0
            if increasesCount != 0 {
                averageIncrease = totalIncrease/increasesCount
                firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
            }
            else {
                firstInfoLabel.text = ""
            }
            
            
            
            
            increasesCount = 0
            totalIncrease = 0
            var newOthers = othersRecords
            newOthers.remove(at: 0)
            
            for j in newOthers {
                for i in 1...j.0.count-1 {
                    if (j.0[i].currentRapid-j.0[i-1].currentRapid) != 0 {
                        totalIncrease += (j.0[i].currentRapid-j.0[i-1].currentRapid)
                        increasesCount += 1
                    }
                    if i == 1 && j.0[i-1].currentRapid != 0 {
                        totalIncrease += j.0[i-1].currentRapid
                        increasesCount += 1
                    }
                }
            }
            if increasesCount != 0 {
                averageIncrease = totalIncrease/increasesCount
                secondInfoLabel.text = "Everyone else increased by an average \(averageIncrease) points every round."
            }
            else {
                secondInfoLabel.text = ""
            }
            
        }
        
        
        
    }
    func showMeGraph() {
        updateMeData()
        LineChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInSine)
        LineChartView.data = meData
        
        if typeSegment.selectedSegmentIndex == 0 {
            var increasesCount = 0
            var totalIncrease = 0
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard) != 0 {
                    totalIncrease += (myRecords.0[i].currentStandard-myRecords.0[i-1].currentStandard)
                    increasesCount += 1
                }
                if i == 1 && myRecords.0[i-1].currentStandard != 0 {
                    totalIncrease += myRecords.0[i-1].currentStandard
                    increasesCount += 1
                }
            }
            if increasesCount != 0 {
                let averageIncrease = totalIncrease/increasesCount
                firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
            }
            else {
                firstInfoLabel.text = ""
            }
            
            
            var maxScore = 0
            var minScore = 9999
            for i in myRecords.0 {
                if i.currentStandard > maxScore {
                    maxScore = i.currentStandard
                }
                if i.currentStandard < minScore {
                    minScore = i.currentStandard
                }
            }
            secondInfoLabel.text = "Your highest and lowest scores are \(maxScore) and \(minScore)."
        }
        else {
            var increasesCount = 0
            var totalIncrease = 0
            for i in 1...myRecords.0.count-1 {
                if (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid) != 0 {
                    totalIncrease += (myRecords.0[i].currentRapid-myRecords.0[i-1].currentRapid)
                    increasesCount += 1
                }
                if i == 1 && myRecords.0[i-1].currentRapid != 0 {
                    totalIncrease += myRecords.0[i-1].currentRapid
                    increasesCount += 1
                }
            }
            if increasesCount != 0 {
                let averageIncrease = totalIncrease/increasesCount
                firstInfoLabel.text = "You increased by an average \(averageIncrease) points every round."
            }
            else {
                firstInfoLabel.text = ""
            }
            
            var maxScore = 0
            var minScore = 9999
            for i in myRecords.0 {
                if i.currentRapid > maxScore {
                    maxScore = i.currentRapid
                }
                if i.currentRapid < minScore {
                    minScore = i.currentRapid
                }
            }
            secondInfoLabel.text = "Your highest and lowest scores are \(maxScore) and \(minScore)."
        }
    }
    
    @IBAction func typeSegmentChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            updateMeData()
            showMeGraph()
        }
        else {
            updateOthersGraph()
            showOthersGraph()
        }
        
    }
    
    
}
