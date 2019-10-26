//
//  LeaderboardFilterViewController.swift
//  ECF App
//
//  Created by Bhuvan on 25/10/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import UIKit

class LeaderboardFilterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var wheel: UIPickerView!
    @IBOutlet weak var gameTypeSwitch: UISwitch!
    
    
    
    var parentVC : LeaderboardViewController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sexSelectChanges(_ sender: UISegmentedControl) {
        if segmentControl.selectedSegmentIndex == 0 {
            filterPrefs.sex = "M"
        }
        else if segmentControl.selectedSegmentIndex == 1 {
            filterPrefs.sex = "F"
        }
        else {
            filterPrefs.sex = "A"
        }
    }
    @IBAction func ratingCapChanges(_ sender: UISlider) {
        filterPrefs.cap = Int(slider.value)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "ALL"
        }
        else {
            return countryList[row-1] + " " //+ flagDict[countryList[row-1]]!
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            filterPrefs.country = "ALL"
        }
        else {
            filterPrefs.country = countryList[row-1]
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        parentVC!.refreshData()
    }
    
    @IBAction func typeChanged(_ sender: Any) {
        if gameTypeSwitch.isOn {
            filterPrefs.gameType = "R"
        }
        else {
            filterPrefs.gameType = "S"
        }
    }
    
    
    
}
