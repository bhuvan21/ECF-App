//
//  LeaderboardViewControllwe.swift
//  ECF App
//
//  Created by Bhuvan on 22/10/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedPlayerCode : String = ""
    var filtered : [PlayerRecord] = []
    var baseFiltered : [PlayerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }
    
    // update the Leaderboard, taking into account filter preferences
    func refreshData() {
        filtered = []

        // Start off filtering with a pre-made set sorted by the game type (rapid or standard)
        if filterPrefs.gameType == "S" {
            baseFiltered = sortedByRating
        }
        else {
            baseFiltered = sortedByRapid
        }
        
        // check if each player meets filter restrictions, and keep only those which do
        for player in baseFiltered {
            var cap = false
            var country = false
            var sex = false
            
            // Apply rating cap
            if filterPrefs.gameType == "S" {
                if filterPrefs.cap >= player.currentStandard {
                    cap = true
                }
            }
            else {
                if filterPrefs.cap >= player.currentRapid {
                    cap = true
                }
            }
            
            // Apply country filter
            if filterPrefs.country == "ALL" {
                country = true
            }
            else if filterPrefs.country == player.nation {
                country = true
            }
            
            // Apply sex filter
            if filterPrefs.sex == "A" {
                sex = true
            }
            else if filterPrefs.sex == player.sex {
                sex = true
            }
            
            if sex && cap && country {
                filtered.append(player)
            }
        }
        
        tableView.reloadData()
    }
    
    
    // TableView Delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(100, filtered.count)
    }
    
    // Responsible for each cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        let player = filtered[indexPath.row]
        
        // Fill in name and sex (add GM if player is GM)
        cell.playerName.text = player.name + " (" + player.sex + ")"
        if grandmasters.contains(String(player.fideCode)) {
            cell.playerName.text = "GM " + player.name + " (" + player.sex + ")"
        }
        
        // Add ratings information, as well as whether they have improved their standard rating in the last season
        cell.standardRating.text = String(player.currentStandard) + player.standardCategory
        cell.rapidRating.text = String(player.currentRapid) + player.rapidCategory
        if player.currentStandard - player.previousStandard > 0 {
            cell.extraInfo.text = "☝️"
        }
        else if player.currentStandard - player.previousStandard == 0 {
            cell.extraInfo.text = "➖"
        }
        else {
            cell.extraInfo.text = "👇"
        }
        
        // Display player's country flag if possible, otherwise keep 3 letter country code
        if flagDict.keys.contains(player.nation) {
            cell.extraInfo.text = cell.extraInfo.text! + flagDict[player.nation]!
        }
        else {
            print(player.nation)
            cell.extraInfo.text = cell.extraInfo.text! + player.nation
        }

        return cell
    }
    
    // Save selected player code and initiate segue to detail view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayerCode = filtered[indexPath.row].reference
        performSegue(withIdentifier: "playerDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Move to detail view, passing on selected player code
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "playerDetail" {
            let vc = segue.destination as! ProfileViewController
            vc.playerLookup = selectedPlayerCode
            vc.isDetail = true;
        }
        else if segue.identifier == "filterDetail" {
            let vc = segue.destination as! LeaderboardFilterViewController
            vc.parentVC = self
        }
    }
    
    // Required for the unwind segue from filter view controller to work
    @IBAction func unwindToname(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    

}
