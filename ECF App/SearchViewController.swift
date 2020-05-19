//
//  SearchViewController.swift
//  ECF App
//
//  Created by Bhuvan on 24/10/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedPlayerCode : String = ""
    var searching : Bool = false
    var filtered : [PlayerRecord] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        tableView.tableHeaderView = searchController.searchBar
        showFavourites()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showFavourites()
    }
    
    // Populate table view with favourites, sorted alphabetically (includes peers)
    func showFavourites() {
        if searchController.searchBar.text!.count < 3 {
            var new_filtered : [PlayerRecord] = []
            for code in (UserDefaults.standard.object(forKey: "favourites") as! [String]) {
                new_filtered.append(getRecords(referenceCode: code).0.last!)
            }
            filtered = new_filtered.sorted { $0.name < $1.name}
            tableView.reloadData()
        }
    }
    
    // Update the displayed entries in the table view based on search dialogue
    func updateSearchResults(for searchController: UISearchController) {
        
        // Only start searching once more than 3 characters have been typed (otherwise performance becomes an issue)
        if searchController.searchBar.text!.count >= 3 {
            searching = true
            filtered = []
            
            // Player should show up if any of the searched words fail to show up in their name
            for player in recentData {
                var flag = true
                for keyword in searchController.searchBar.text!.split(separator: " "){
                    if !player.name.replacingOccurrences(of: ",", with: " ").lowercased().contains(keyword.lowercased()) {
                        flag = false
                    }
                }
                
                if flag {
                    filtered.append(player)
                }
                
                // Limit to 50 results
                if filtered.count >= 50 {
                    break
                }
            }
        }
            
        else {
            // If searching is not occuring, show the user's favourites (this includes peers)
            searching = false
            var new_filtered : [PlayerRecord] = []
            for code in (UserDefaults.standard.object(forKey: "favourites") as! [String]) {
                new_filtered.append(getRecords(referenceCode: code).0.last!)
            }
            // Sort the favourites by alphabetical order
            filtered = new_filtered.sorted { $0.name < $1.name}
        }
        tableView.reloadData()
    }
    
    // Table View delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text != "" && searchController.searchBar.text!.count >= 3 {
            return filtered.count
        }
        else {
            return (UserDefaults.standard.object(forKey: "favourites") as! [String]).count
        }
        
    }
    
    // Responsible for every table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        let player = filtered[indexPath.row]
        
        // If player is a peer, add a text indicator. Also add sex indicator
        if (UserDefaults.standard.object(forKey: "peers") as! [String]).contains(player.reference) {
            cell.playerName.text = "(Peer) " + player.name + " (" + player.sex + ")"
        }
        else {
            cell.playerName.text = player.name + " (" + player.sex + ")"
        }
        
        // If player is a GM, show GM
        if grandmasters.contains(String(player.fideCode)) {
            cell.playerName.text = "GM " + cell.playerName.text!
        }
        
        // Show each player's ratings + improvement
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
        
        // Show each player's country's flag (if possible)
        if flagDict.keys.contains(player.nation) {
            cell.extraInfo.text = cell.extraInfo.text! + flagDict[player.nation]!
        }
        else {
            cell.extraInfo.text = cell.extraInfo.text! + player.nation
        }

        return cell
    }
    
    // Show detail view controller if player is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayerCode = filtered[indexPath.row].reference
        performSegue(withIdentifier: "playerDetail", sender: nil)
    }
    
    // Pass the selected player's ref code to the detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ProfileViewController
        vc.playerLookup = selectedPlayerCode
        vc.isDetail = true;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController.isActive = false
    }
}
