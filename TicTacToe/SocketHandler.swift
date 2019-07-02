//
//  SocketHandler.swift
//  TicTacToe
//
//  Created by Neil Richter on 26/06/2019.
//  Copyright © 2019 Neil Richter. All rights reserved.
//

import Foundation
import SocketIO

class SocketHandler {
    var manager: SocketManager;
    var socket: SocketIOClient;
    
    static let shared = SocketHandler()

    init() {
        self.manager = SocketManager(socketURL: URL(string: "http://51.254.112.146:5666")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
}
