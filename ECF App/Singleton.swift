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
