//
//  DataLoadViewController.swift
//  ECF App
//
//  Created by Bhuvan Belur on 16/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class DataLoadViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for csv in csvFilenames {
            let dataString : String = stringFromCSV(fileName: csv)!
            var rows = dataString.components(separatedBy: "\n")
            rows.remove(at: 0)
            var csv : [PlayerRecord] = []
            
            var names : [String] = []
            /*"308000G","Belur, Ankita","F","","A",76,61,35,"A",89,71,87,"Middlesex Juniors","Barnet Knights","Barnet Juniors","England",,,,*/
            for row in rows {
                
                let line = row
                var values: [String] = []
                if line != "" {
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            value = ""
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(",", into: &value)
                            }
                            
                            values.append(value! as String)
                            
                            if textScanner.scanLocation < textScanner.string.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.components(separatedBy: ",")
                    }
                    
                    
                }
                
                
                let columns = values
                /*
                 record.reference = columns[0]
                 record.name = columns[1] + "," + columns[2]
                 record.sex = columns[3]
                 record.standardCategory = columns[5]
                 record.currentStandard = Int(columns[6]) ?? 0
                 record.previousStandard = Int(columns[7]) ?? 0
                 record.standardGamesPlayed = Int(columns[8]) ?? 0
                 record.rapidCategory = columns[9]
                 record.currentRapid = Int(columns[10]) ?? 0
                 record.previousRapid = Int(columns[11]) ?? 0
                 record.rapidGamesPlayed = Int(columns[12]) ?? 0
                 record.clubs = [columns[13], columns[14], columns[15], columns[16], columns[17], columns[18]]
                 record.fideCode = Int(columns[19]) ?? 0
                 record.nation = columns[20]
                 */
                if columns.count < 20 {
                    print(columns)
                }
                else {
                    var record : PlayerRecord = PlayerRecord(
                        reference: columns[0],
                        name: columns[1],
                        sex: columns[2],
                        standardCategory: columns[4],
                        currentStandard: Int(columns[5]) ?? 0,
                        previousStandard: Int(columns[6]) ?? 0,
                        standardGamesPlayed: Int(columns[7]) ?? 0,
                        rapidCategory: columns[8],
                        currentRapid: Int(columns[9]) ?? 0,
                        previousRapid: Int(columns[10]) ?? 0,
                        rapidGamesPlayed: Int(columns[11]) ?? 0,
                        clubs: [columns[12], columns[13], columns[14], columns[15], columns[16], columns[17]],
                        fideCode : Int(columns[18]) ?? 0,
                        nation : columns[19]
                    )
                    names.append(columns[0])
                    csv.append(record)
                }
                
            }
            data.append(csv)
            dataLookup.append(names)
        }
        print(data[0][0])
        
        for player in data[3] {
            recentData.append(player)
        }

        sortedByRating = recentData.sorted(by: {$0.currentStandard >= $1.currentStandard})
        sortedByRapid = recentData.sorted(by: {$0.currentRapid >= $1.currentRapid})

        performSegue(withIdentifier: "dataLoaded", sender: nil)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func stringFromCSV(fileName:String) -> String? {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "csv")
            else {
                return nil
        }
        do {

            let contents = try String(contentsOfFile: filepath, encoding: String.Encoding.isoLatin1)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            print("Error info: \(error)")
            return nil

        }
    }
    
    
}
