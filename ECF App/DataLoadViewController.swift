//
//  DataLoadViewController.swift
//  ECF App
//
//  Created by Bhuvan Belur on 16/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class DataLoadViewController: UIViewController {
    
    var version = 4

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var firstTimeLabel: UILabel!
    
    var excuses = ["Beating all the grandmasters", "Checking if the new ratings are out", "Seeing what Magnus Carlsen is up to", "Working on my endgames", "Forking your queen and king", "Castling", "Not now! I'm playing a blitz game", "Oops! I blundered", "Wait, we're not playing 3D chess?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.startAnimating()
        if UserDefaults.standard.object(forKey: "favourites") == nil {
            let empty : [String] = []
            UserDefaults.standard.set(empty, forKey: "favourites")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

        DispatchQueue.global(qos: .userInitiated).async {
            var test = UserDefaults.standard.object(forKey: "version")
            var newtest = 0
            if test != nil {
                newtest = test as! Int
            }
            print("is data")
            print(UserDefaults.standard.object(forKey: "data") == nil)
            print(self.version)
            print(newtest)
            if UserDefaults.standard.object(forKey: "data") == nil || newtest != self.version {
                DispatchQueue.main.async {
                    self.firstTimeLabel.text = "NB : The app will take longer to load the first time"
                }
                
                self.updateProgress(i: 0, j: csvFilenames.count+6)
                var iProgress = 0
                for csv in csvFilenames {
                    let dataString : String = self.stringFromCSV(fileName: csv)!
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
                    iProgress += 1
                    self.updateProgress(i: iProgress, j: csvFilenames.count+6)
                    data.append(csv)
                    dataLookup.append(names)
                }
                UserDefaults.standard.set(try? PropertyListEncoder().encode(data), forKey:  "data")
                print("is data")
                print(UserDefaults.standard.object(forKey: "data") == nil)
                self.updateProgress(i: iProgress+1, j: csvFilenames.count+5)
                //UserDefaults.standard.set(dataLookup, forKey: "dataLookup")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(dataLookup), forKey:  "dataLookup")
                
                for player in data.last! {
                    recentData.append(player)
                }
                //UserDefaults.standard.set(recentData, forKey: "recentData")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(recentData), forKey:  "recentData")
                self.updateProgress(i: iProgress+2, j: csvFilenames.count+6)
                sortedByRating = recentData.sorted(by: {$0.currentStandard >= $1.currentStandard})
                self.updateProgress(i: iProgress+3, j: csvFilenames.count+6)
                sortedByRapid = recentData.sorted(by: {$0.currentRapid >= $1.currentRapid})
                self.updateProgress(i: iProgress+4, j: csvFilenames.count+6)
                //UserDefaults.standard.set(sortedByRapid, forKey: "sortedByRapid")
                //UserDefaults.standard.set(sortedByRating, forKey: "sortedByRating")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sortedByRapid), forKey:  "sortedByRapid")
                self.updateProgress(i: iProgress+5, j: csvFilenames.count+6)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sortedByRating), forKey:  "sortedByRating")
                self.updateProgress(i: iProgress+6, j: csvFilenames.count+6)
                UserDefaults.standard.set(self.version, forKey: "version")
            }
            else {
                
                self.updateProgress(i: 0, j: 5)
                DispatchQueue.main.async {
                    self.firstTimeLabel.text = ""
                }
                print("we out")
                if let d = UserDefaults.standard.object(forKey: "data") as? Data {
                    data = try! PropertyListDecoder().decode(Array<Array<PlayerRecord>>.self, from:d)
                }
                print("uh")
                
                self.updateProgress(i: 1, j: 5)
                if let d = UserDefaults.standard.object(forKey: "dataLookup") as? Data {
                    dataLookup = try! PropertyListDecoder().decode(Array<Array<String>>.self, from:d)
                }
                print("tf")
                self.updateProgress(i: 2, j: 5)
                if let d = UserDefaults.standard.object(forKey: "recentData") as? Data {
                    recentData = try! PropertyListDecoder().decode(Array<PlayerRecord>.self, from:d)
                }
                self.updateProgress(i: 3, j: 5)
                if let d = UserDefaults.standard.object(forKey: "sortedByRating") as? Data {
                    sortedByRating = try! PropertyListDecoder().decode(Array<PlayerRecord>.self, from:d)
                }
                self.updateProgress(i: 4, j: 5)
                if let d = UserDefaults.standard.object(forKey: "sortedByRapid") as? Data {
                    sortedByRapid = try! PropertyListDecoder().decode(Array<PlayerRecord>.self, from:d)
                }
                self.updateProgress(i: 5, j: 5)
                
                
                

            }
            

            if UserDefaults.standard.object(forKey: "identity") == nil {
                UserDefaults.standard.set(playerReference, forKey: "identity")
            }
            else {
                playerReference = UserDefaults.standard.object(forKey: "identity") as! String
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "dataLoaded", sender: nil)
            }
            
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
    
    func updateProgress(i:Int, j:Int) {
        DispatchQueue.main.async {
            self.progress.setProgress(Float(i)/Float(j), animated: false)
            print(Float(i)/Float(j))
            var x = self.excuses.randomElement()!+"..."
            while x == self.loadLabel.text! + "..." {
                x = self.excuses.randomElement()!+"..."
            }
            self.loadLabel.text = self.excuses.randomElement()
            print("done")
        }
        print("ddone")
        
        
    }
    
    
}
