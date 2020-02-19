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
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count >= 3 {
            searching = true
            filtered = []
            
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
                
                if filtered.count >= 100 {
                    break
                }
            }
            
        }
        else {
            searching = false
            var new_filtered : [PlayerRecord] = []
            for code in (UserDefaults.standard.object(forKey: "favourites") as! [String]) {
                new_filtered.append(getRecords(referenceCode: code).0.last!)
            }
            filtered = new_filtered.sorted { $0.name < $1.name}
        }
        tableView.reloadData()
    }
    
    
    
    var filtered : [PlayerRecord] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text != "" && searchController.searchBar.text!.count >= 3 {
            return filtered.count
        }
        else {
            return (UserDefaults.standard.object(forKey: "favourites") as! [String]).count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        
        var players : [PlayerRecord] = []
        
        players = filtered
        print(players)
        print(indexPath.row)
        
        let player = players[indexPath.row]
        print(player, "CELLFORROWAT")
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        // Do any additional setup after loading the view.
        tableView.tableHeaderView = searchController.searchBar
        if searchController.searchBar.text!.count < 3 {
            var new_filtered : [PlayerRecord] = []
            for code in (UserDefaults.standard.object(forKey: "favourites") as! [String]) {
                print(code, getRecords(referenceCode: code).0[0])
                new_filtered.append(getRecords(referenceCode: code).0.last!)
            }
            filtered = new_filtered.sorted { $0.name < $1.name}
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if searchController.searchBar.text!.count < 3 {
            var new_filtered : [PlayerRecord] = []
            for code in (UserDefaults.standard.object(forKey: "favourites") as! [String]) {
                print(code, getRecords(referenceCode: code).0.last!)
                new_filtered.append(getRecords(referenceCode: code).0.last!)
            }
            filtered = new_filtered.sorted { $0.name < $1.name}
            tableView.reloadData()
        }
        print((UserDefaults.standard.object(forKey: "favourites") as! [String]).count, "COUNT")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPlayerCode = filtered[indexPath.row].reference
        performSegue(withIdentifier: "playerDetail", sender: nil)
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destination as! ProfileViewController
        vc.playerLookup = selectedPlayerCode
        vc.isDetail = true;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("leaving")
        
        searchController.isActive = false
    }
    

}
