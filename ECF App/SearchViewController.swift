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
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count >= 3 {
            filtered = []
            for player in recentData {
                var flag = true
                for keyword in searchController.searchBar.text!.split(separator: " "){
                    if !player.name.replacingOccurrences(of: ",", with: " ").contains(keyword) {
                        flag = false
                    }
                }
                if flag {
                    filtered.append(player)
                }
            }
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
            return 100
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        
        var players : [PlayerRecord] = []
        
        if searchController.searchBar.text != "" && searchController.searchBar.text!.count >= 3{
            players = filtered
        }
        else {
            players = recentData
        }
        
        
        let player = players[indexPath.row]
        cell.playerName.text = player.name + " (" + player.sex + ")"
        cell.standardRating.text = String(player.currentStandard)
        cell.rapidRating.text = String(player.currentRapid)
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" && searchController.searchBar.text!.count >= 3{
            selectedPlayerCode = filtered[indexPath.row].reference
        }
        else {
            selectedPlayerCode = recentData[indexPath.row].reference
        }
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
