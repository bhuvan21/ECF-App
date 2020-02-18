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

        // Do any additional setup after loading the view.
        print("i loadd")
        refreshData()
    }
    
    func refreshData() {
        filtered = []
        print(filterPrefs)
        if filterPrefs.gameType == "S" {
            baseFiltered = sortedByRating
            print(baseFiltered[0])
        }
        else {
            baseFiltered = sortedByRapid
        }
        for player in baseFiltered {
            var cap = false
            var country = false
            var sex = false
            
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
            
            if filterPrefs.country == "ALL" {
                country = true
            }
            else if filterPrefs.country == player.nation {
                country = true
            }
            
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(100, filtered.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        let player = filtered[indexPath.row]
        
        cell.playerName.text = player.name + " (" + player.sex + ")"
        
        if grandmasters.contains(String(player.fideCode)) {
            cell.playerName.text = "GM " + player.name + " (" + player.sex + ")"
        }
        
        
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
        
        if flagDict.keys.contains(player.nation) {
            cell.extraInfo.text = cell.extraInfo.text! + countryToFlag(country: player.nation)
        }
        else {
            cell.extraInfo.text = cell.extraInfo.text! + player.nation
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayerCode = filtered[indexPath.row].reference
        performSegue(withIdentifier: "playerDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
    @IBAction func unwindToname(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    

}
