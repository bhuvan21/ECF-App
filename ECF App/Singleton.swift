//
//  Singleton.swift
//  ECF App
//
//  Created by Bhuvan Belur on 16/08/2019.
//  Copyright © 2019 Bhuvan Belur. All rights reserved.
//

import Foundation

struct PlayerRecord {
    var reference : String
    var name : String
    var sex : String
    var standardCategory : String
    var currentStandard : Int
    var previousStandard : Int
    var standardGamesPlayed : Int
    var rapidCategory : String
    var currentRapid : Int
    var previousRapid : Int
    var rapidGamesPlayed : Int
    var clubs : [String]
    var fideCode : Int
    var nation : String
}

var data : [[PlayerRecord]] = [];
var dataLookup : [[String]] = [];

func getRecords(referenceCode:String) ->[PlayerRecord] {
    var records : [PlayerRecord] = []
    var i : Int = 0
    for nameList in dataLookup {
        let index = nameList.firstIndex(of: referenceCode)

        records.append(data[i][index ?? 0])
        i = i + 1
    }
    return records
}

var csvFilenames : [String] = ["grades201901", "grades201907"]
var csvDates : [String] = ["01/19", "07/19"]

var playerReference : String = ""
