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


var recentData : [PlayerRecord] = [];

var sortedByRating : [PlayerRecord] = []




var csvFilenames : [String] = ["grades201907", "grades201901"]
var csvDates : [String] = ["07/19", "01/19"]

var playerReference : String = ""


var flagDict : [String:String] = ["ENG":"🏴󠁧󠁢󠁥󠁮󠁧󠁿", "USA":"🇺🇸", "RUS":"🇷🇺", "POL":"🇵🇱", "CHN":"🇨🇳", "FRA":"🇫🇷", "NED":"🇳🇱", "UKR":"🇺🇦", "IND":"🇮🇳", "ESP":"🇪🇸", "HUN":"🇭🇺", "ARM":"🇦🇲", "AZE":"🇦🇿", "BLR":"🇧🇾", "SWE":"🇸🇪", "VIE":"🇻🇳", "CZE":"🇨🇿", "CRO":"🇭🇷", "GEO":"🇬🇪", "ISR":"🇮🇱", "ROU":"🇷🇴", "GER":"🇩🇪", "NOR":"🇳🇴", "ITA":"🇮🇹", "MAS":"🇲🇾", "SRB":"🇷🇸", "KAZ":"🇰🇿", "SUI":"🇨🇭", "ISL":"🇮🇸"];


func countryToFlag(country: String) -> String {
    return flagDict[country]!
}
