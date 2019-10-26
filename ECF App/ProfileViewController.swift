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
    
    
    var playerLookup : String = "308000G";
    var isDetail = false
    var records : [PlayerRecord] = []
    
    
    var standardScores : [Int] = []
    var standardCategories : [String] = []
    var rapidScores : [Int] = []
    var rapidCategories : [String] = []
    var dataDates : [String] = []
    var clubList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        print("reloading")
        if isDetail == false {
            playerLookup = playerReference
        }
        print(playerLookup)
        
        standardScores = []
        standardCategories = []
        rapidScores = []
        rapidCategories = []
        dataDates = []
        // Do any additional setup after loading the view.
        let raw = getRecords(referenceCode: playerLookup)
        records = raw.0

        let dates = raw.1
        let namesplit = records[0].name.components(separatedBy: ",")
        
        nameLabel.text = namesplit[1] + " " + namesplit[0]
        basicInfoLabel.text = records[0].clubs[0] + " | (" + records[0].sex + ")"
        detailLabel.text = "#" + records[0].reference + ", FIDE: " + String(records[0].fideCode) + ", Nation: " + records[0].nation
        
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
        
        clubList = []
        for r in records {
            for c in r.clubs {
                if !clubList.contains(c) {
                    clubList.append(c)
                }
            }
        }
        
        
        tableView.reloadData()
        collectionView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clubList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "club", for: indexPath) as! ClubCollectionViewCell
        cell.clubLabel.text = clubList[indexPath.row]
        return cell
    }

}
