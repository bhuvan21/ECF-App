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

func getRecords(referenceCode:String) ->(records:[PlayerRecord], dates:[String]) {
    var records : [PlayerRecord] = []
    var dates : [String] = []
    var i : Int = 0
    for nameList in dataLookup {
        
        let index = nameList.firstIndex(of: referenceCode)
        if !(index ?? -1 == -1) {
            records.append(data[i][index!])
            dates.append(csvDates[i])
        }
        
        i = i + 1
    }
    return (records, dates)
}


var recentData : [PlayerRecord] = [];

var sortedByRating : [PlayerRecord] = []
var sortedByRapid: [PlayerRecord] = []



var csvFilenames : [String] = ["grades201801", "grades201807", "grades201901", "grades201907"]
var csvDates : [String] = ["01/18", "07/18" , "01/19", "07/19"]

var playerReference : String = "308000G"


var flagDict : [String:String] = ["ENG":"🏴󠁧󠁢󠁥󠁮󠁧󠁿", "USA":"🇺🇸", "RUS":"🇷🇺", "POL":"🇵🇱", "CHN":"🇨🇳", "FRA":"🇫🇷", "NED":"🇳🇱", "UKR":"🇺🇦", "IND":"🇮🇳", "ESP":"🇪🇸", "HUN":"🇭🇺", "ARM":"🇦🇲", "AZE":"🇦🇿", "BLR":"🇧🇾", "SWE":"🇸🇪", "VIE":"🇻🇳", "CZE":"🇨🇿", "CRO":"🇭🇷", "GEO":"🇬🇪", "ISR":"🇮🇱", "ROU":"🇷🇴", "GER":"🇩🇪", "NOR":"🇳🇴", "ITA":"🇮🇹", "MAS":"🇲🇾", "SRB":"🇷🇸", "KAZ":"🇰🇿", "SUI":"🇨🇭", "ISL":"🇮🇸"];

var countryList = ["ENG", "USA", "RUS", "POL", "CHN", "FRA", "NED", "UKR", "IND", "ESP", "HUN", "ARM", "AZE", "BLR", "SWE", "VIE", "CZE", "CRO", "GEO", "ISR", "ROU", "GER", "NOR", "ITA", "MAS", "SRB", "KAZ", "SUI", "ISL"]

func countryToFlag(country: String) -> String {
    return flagDict[country]!
}


struct filterSettings {
    var sex : String
    var cap : Int
    var country : String
    var gameType : String
}

var filterPrefs = filterSettings(sex: "A", cap: 300, country: "ALL", gameType:"S")
