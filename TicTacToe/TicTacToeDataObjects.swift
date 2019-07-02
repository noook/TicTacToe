//
//  TicTacToeDataObjects.swift
//  TicTacToe
//
//  Created by Neil Richter on 02/07/2019.
//  Copyright © 2019 Neil Richter. All rights reserved.
//

import Foundation

struct JoinGame {
    var currentTurn: String
    var playerO: String
    var playerX: String
}

struct Movement {
    var index: Int?
    var win: Bool?
    var player_played: String?
    var player_play: String?
    var err: String?
    
    init(_ data: [String: Any]) {
        if let err = data["err"] as? String {
            self.err = err
        }
        else {
            self.err = nil
            self.index = (data["index"] as! Int)
            self.win = (data["win"] as! Bool)
            self.player_played = (data["player_played"] as! String)
            self.player_play = (data["player_play"] as! String)
        }
    }
}
