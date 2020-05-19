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
    
    var excuses = ["Beating all the grandmasters", "Hoping my rating will go up this season", "Seeing what Magnus Carlsen is up to", "Working on my endgames", "Forking your queen and king", "Castling", "Not now! I'm playing a blitz game", "Oops! I blundered", "Wait, we're not playing 3D chess?"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.startAnimating()
        
        // if the app has not been opened before, create the relevant objects in UserDefaults with empty values
        let empty : [String] = []
        if UserDefaults.standard.object(forKey: "favourites") == nil {
            
            UserDefaults.standard.set(empty, forKey: "favourites")
        }
        
        if UserDefaults.standard.object(forKey: "peers") == nil {
            UserDefaults.standard.set(empty, forKey: "peers")
        }
        
        if UserDefaults.standard.object(forKey: "identity") == nil {
            UserDefaults.standard.set(playerReference, forKey: "identity")
        }
        else {
            playerReference = UserDefaults.standard.object(forKey: "identity") as! String
        }
        
        countryList = Array<String>(flagDict.keys)
    }
    
    // Connects to the database of players, and loads important sorted data into variables
    // I believe this ends up being more performant than querying the database on the fly, and results in a (not too long)
    // loading period on launcing of the app, but next to no loading time through the rest of the app
    // Potentially could be improved by querying database whenever data is wanted, but I think this would not be massively significant
    override func viewDidAppear(_ animated: Bool) {
        
        // Carry out loading data in the background so as not to clog main UI thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Connect to the local database, update progress as more loading steps are taken
            self.updateProgress(i: 0, j: 5)
            let dbUrl = Bundle.main.url(forResource: "players", withExtension: "sqlite3")!
            let dbPath = dbUrl.path
            database = try! Connection(dbPath)
            self.updateProgress(i: 1, j: 5)
            
            recentData = []
            do {
                // Pre-load the most recent set of data into "recentData" for quick access later
                var query = table.filter(date == newestDate)
                for player in try database.prepare(query) {
                    recentData.append(rowToRecord(player: player))
                }
                
                // Pre load other sorted sets
                self.updateProgress(i: 2, j: 5)
                sortedByRating = []
                query = table.filter(date == newestDate).order(9999 - currentStandard)
                for player in try database.prepare(query) {
                    sortedByRating.append(rowToRecord(player: player))
                }
                
                self.updateProgress(i: 3, j: 5)
                sortedByRapid = []
                query = table.filter(date == newestDate).order(9999 - currentRapid)
                for player in try database.prepare(query) {
                    sortedByRapid.append(rowToRecord(player: player))
                }
                self.updateProgress(i: 4, j: 5)
                
                // Leave the data loading page, UI is called on main thread
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "dataLoaded", sender: nil)
                }
                self.updateProgress(i: 5, j: 5)
            }
                
            catch {
                // This should only ever be reached if the database cannot be connected to properly, which should never happen as it is
                // stored locally and is completely static
                print(error)
            }
        }
    }
    
    // Update progress indicator on the main thread
    // Choose new "fun" message and move along progress bar
    func updateProgress(i:Int, j:Int) {
        
        DispatchQueue.main.async {
            self.progress.setProgress(Float(i)/Float(j), animated: false)
            // Ensure new message is not the same as old message
            var x = self.excuses.randomElement()!+"..."
            while x == self.loadLabel.text! + "..." {
                x = self.excuses.randomElement()!+"..."
            }
            self.loadLabel.text = self.excuses.randomElement()
        }
    }
}
