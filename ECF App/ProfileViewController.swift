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
        
        if (UserDefaults.standard.object(forKey: "first") == nil) && isDetail == false{
            UserDefaults.standard.set(false, forKey: "first")
            let myAlert = UIAlertController(title:"Choose Your Profile", message: "First time using this app? We don't yet know who you are so the 'My Profile' section currently displays a random user. To select yourself, find yourself on the search tab and click the person shaped button.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            myAlert.addAction(action)
            self.present(myAlert, animated: true, completion: nil)
            
        }
        if isDetail {
            selectMeButton.isHidden = false
        }
        else {
            selectMeButton.isHidden = true
        }
        
        
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (UserDefaults.standard.object(forKey: "favourites") as! [String]).contains(playerLookup) {
            favouriteMeButton.setImage(UIImage(named:"filled"), for: .normal)
        }
        else {
            favouriteMeButton.setImage(UIImage(named:"unfilled"), for: .normal)
        }
        
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
    
    @IBAction func meSelected(_ sender: Any) {
        
        playerReference = playerLookup
                   UserDefaults.standard.set(playerLookup, forKey: "identity")
                   let myAlert = UIAlertController(title:"Succesfully set your identity", message: "", preferredStyle: .alert)
                   let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                   myAlert.addAction(action)
                   self.present(myAlert, animated: true, completion: nil)
    }
    

    @IBAction func meFavourited(_ sender: Any) {
        
       
        
        

        let favs = UserDefaults.standard.object(forKey: "favourites") as! [String]
            if favs.contains(playerLookup) {
                print("contains")
                var new_favs : [String] = favs
                new_favs.remove(at: new_favs.index(of: playerLookup)!)
                UserDefaults.standard.set(new_favs, forKey:"favourites")
            }
            else {
                print("doesnt")
                var new_favs : [String] = favs
                new_favs.append(playerLookup)
                
                UserDefaults.standard.set(new_favs, forKey:"favourites")
            }
            print(favouriteMeButton.imageView!.image)
            if favouriteMeButton.imageView!.image == UIImage(named: "unfilled") {
                favouriteMeButton.setImage(UIImage(named:"filled"), for: .normal)
                print("making filled")
            }
            else {
                favouriteMeButton.setImage(UIImage(named:"unfilled"), for: .normal)
                print("making unfilled")
            }
    }
    
        
            
        
    }
