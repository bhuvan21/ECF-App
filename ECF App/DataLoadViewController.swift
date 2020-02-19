//
//  DataLoadViewController.swift
//  ECF App
//
//  Created by Bhuvan Belur on 16/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit
import SQLite

class DataLoadViewController: UIViewController {
    
    var version = 6

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
        if UserDefaults.standard.object(forKey: "peers") == nil {
            let empty : [String] = []
            UserDefaults.standard.set(empty, forKey: "peers")
            print("set")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.updateProgress(i: 0, j: 5)
            let dbUrl = Bundle.main.url(forResource: "players", withExtension: "sqlite3")!
            let dbPath = dbUrl.path
            database = try! Connection(dbPath)
            
            recentData = []
            self.updateProgress(i: 1, j: 5)
            do {
                var query = table.filter(date == newestDate)
                for player in try database.prepare(query) {
                    recentData.append(rowToRecord(player: player))
                }
                self.updateProgress(i: 2, j: 5)
                sortedByRating = []
                query = table.filter(date == newestDate).order(999 - currentStandard)
                for player in try database.prepare(query) {
                    sortedByRating.append(rowToRecord(player: player))
                }
                self.updateProgress(i: 3, j: 5)
                sortedByRapid = []
                query = table.filter(date == newestDate).order(999 - currentRapid)
                for player in try database.prepare(query) {
                    sortedByRapid.append(rowToRecord(player: player))
                }
                self.updateProgress(i: 4, j: 5)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "dataLoaded", sender: nil)
                }
                self.updateProgress(i: 5, j: 5)
                
            }
            catch {
                print(error)
            }

                
            
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
