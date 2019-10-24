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
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLAYER") as! PlayerTableViewCell
        let player = sortedByRating[indexPath.row]
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
        print(player.nation)
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
