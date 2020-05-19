//
//  ProfileViewController.swift
//  ECF App
//
//  Created by Bhuvan Belur on 17/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var basicInfoLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectMeButton: UIButton!
    @IBOutlet weak var favouriteMeButton: UIButton!
    
    // local variable for displayed player's ref code. Set by prev view controller most of the time
    var playerLookup : String = "308000G";
    var isDetail = false
    var records : [PlayerRecord] = []
    
    // arrays for easy data displaying
    var standardScores : [Int] = []
    var standardCategories : [String] = []
    var rapidScores : [Int] = []
    var rapidCategories : [String] = []
    var dataDates : [String] = []
    var clubList : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if this is the first time the app has been launched, show an informative prompt
        if (UserDefaults.standard.object(forKey: "first") == nil) && isDetail == false{
            UserDefaults.standard.set(false, forKey: "first")
            let myAlert = UIAlertController(title:"Choose Your Profile", message: "First time using this app? We don't yet know who you are so the 'My Profile' section currently displays a random user. To select yourself, find yourself on the search tab and click the person shaped button.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            myAlert.addAction(action)
            self.present(myAlert, animated: true, completion: nil)
        }
        
        selectMeButton.tintColor = UIColor.systemBlue
        
        // Change what UI is available based on what purpose the view is serving (user viewing themself, or someone else
        if isDetail {
            selectMeButton.isHidden = false
        }
        else {
            selectMeButton.isHidden = true
        }
        
        reloadData()
    }
    
    // If the player being viewed is a favourite or peer, adjust the favourite button's state to reflect this
    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.object(forKey: "favourites") as! [String]).contains(playerLookup) {
            if (UserDefaults.standard.object(forKey: "peers") as! [String]).contains(playerLookup) {
                favouriteMeButton.setImage(UIImage(named:"peer"), for: .normal)
                favouriteMeButton.tintColor = UIColor.green
            }
            else {
                favouriteMeButton.setImage(UIImage(named:"filled"), for: .normal)
                favouriteMeButton.tintColor = UIColor.systemBlue
            }
        }
        else {
           favouriteMeButton.setImage(UIImage(named:"unfilled"), for: .normal)
           favouriteMeButton.tintColor = UIColor.systemBlue
       }
       reloadData()
    }
    
    // Actually set labels to contain information
    func reloadData() {
        if isDetail == false {
            playerLookup = playerReference
        }
        
        standardScores = []
        standardCategories = []
        rapidScores = []
        rapidCategories = []
        dataDates = []
        
        // Get player's data
        let raw = getRecords(referenceCode: playerLookup)
        records = raw.0
        let dates = raw.1
        let namesplit = records[0].name.components(separatedBy: ",")
        
        // Set player's name information
        nameLabel.text = namesplit[1] + " " + namesplit[0]
        if records[0].sex == "" {
            basicInfoLabel.text = records[0].clubs[0]
        }
        else {
            basicInfoLabel.text = records[0].clubs[0] + " | (" + records[0].sex + ")"
        }
        
        // Set secondary information (REF, FIDE, NATION)
        detailLabel.text = "#" + records[0].reference + ", FIDE: " + String(records[0].fideCode) + ", Nation: " + records[0].nation
        
        // Sort player's scores by chronological order
        var i : Int = 0;
        for s in records.reversed() {
            dataDates.append(dates[(dates.count-i)-1])
            standardScores.append(s.currentStandard)
            
            if s.standardCategory == "" {
                standardCategories.append("None")
            }
            else {
                standardCategories.append(s.standardCategory)
            }
            
            rapidScores.append(s.currentRapid)
            if s.rapidCategory == "" {
                rapidCategories.append("None")
            }
            else {
                rapidCategories.append(s.rapidCategory)
            }
            
            i = i + 1
        }
        
        // Collate all the player's clubs
        clubList = []
        for r in records {
            for c in r.clubs {
                if !clubList.contains(c) {
                    clubList.append(c)
                }
            }
        }
        
        // Apply the tableView and collectionView data changes
        tableView.reloadData()
        collectionView.reloadData()
    }

    // Table View delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count + 1
    }
    
    // Responsible for all cells in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Insert a title row
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as! ScoresTableViewCell

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath) as! ScoresTableViewCell
            let index = indexPath.row - 1
            cell.dateLabel.text = dataDates[index]
            cell.standardCategoryLabel.text = standardCategories[index]
            cell.standardScoreLabel.text = String(standardScores[index])
            cell.rapidCategoryLabel.text = rapidCategories[index]
            cell.rapidScoreLabel.text = String(rapidScores[index])
            return cell
        }
    }
    
    // Collection View delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clubList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "club", for: indexPath) as! ClubCollectionViewCell
        cell.clubLabel.text = clubList[indexPath.row]
        return cell
    }
    
    // Set the user's identity as this player internally, and show this has happened with an alert
    @IBAction func meSelected(_ sender: Any) {
        playerReference = playerLookup
        UserDefaults.standard.set(playerLookup, forKey: "identity")
        let myAlert = UIAlertController(title:"Succesfully set your identity", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // Handles selection of this player as a peer or favourite, depending on how the player is classed currently
    @IBAction func meFavourited(_ sender: Any) {
        let favs = UserDefaults.standard.object(forKey: "favourites") as! [String]
        let peers = UserDefaults.standard.object(forKey: "peers") as! [String]
        
        // If player is not favourite or peer, make them a favourite
        if favouriteMeButton.imageView!.image == UIImage(named: "unfilled") {
            favouriteMeButton.setImage(UIImage(named:"filled"), for: .normal)
            var new_favs : [String] = favs
            new_favs.append(playerLookup)
            UserDefaults.standard.set(new_favs, forKey:"favourites")
        }
        // If player is a favourite, make them a peer
        else if favouriteMeButton.imageView!.image == UIImage(named: "filled") {
            favouriteMeButton.setImage(UIImage(named:"peer"), for: .normal)
            var new_peers : [String] = peers
            new_peers.append(playerLookup)
            favouriteMeButton.tintColor = UIColor.systemGreen
            UserDefaults.standard.set(new_peers, forKey:"peers")
        }
        // Otherwise, they are a peer, so unfavourite and unpeer them
        else {
            var new_favs : [String] = favs
            var new_peers : [String] = peers
            new_favs.remove(at: new_favs.index(of: playerLookup)!)
            new_peers.remove(at: new_peers.index(of: playerLookup)!)
            favouriteMeButton.setImage(UIImage(named:"unfilled"), for: .normal)
            UserDefaults.standard.set(new_peers, forKey:"peers")
            UserDefaults.standard.set(new_favs, forKey:"favourites")
            favouriteMeButton.tintColor = UIColor.systemBlue
        }
    }
}
