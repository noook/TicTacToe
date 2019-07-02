//
//  OnlineViewController.swift
//  TicTacToe
//
//  Created by Neil Richter on 26/06/2019.
//  Copyright © 2019 Neil Richter. All rights reserved.
//

import UIKit
import SocketIO
import AVFoundation

class OnlineViewController: UIViewController {
    let socketManager = SocketHandler.shared
    var game: JoinGame!
    var player: String!
    var mark: String!

    func initElements() {
        self.buttons = [
            0: self.Button1,
            1: self.Button2,
            2: self.Button3,
            3: self.Button4,
            4: self.Button5,
            5: self.Button6,
            6: self.Button7,
            7: self.Button8,
            8: self.Button9,
        ]
        self.scoreLabels = [
            0: self.DrawScore,
            1: self.Player1Score,
            2: self.Player2Score,
        ]
        self.resetGrid()
    }

    func setTurn() {
        self.TurnIndicator.text = self.game.currentTurn == self.mark ? "Your turn !" : "Opponent's turn !"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initElements()
        self.initEventListeners()
        self.mark = self.game.playerO == self.player ? "o": "x"

        self.setTurn()

    }

    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button5: UIButton!
    @IBOutlet weak var Button6: UIButton!
    @IBOutlet weak var Button7: UIButton!
    @IBOutlet weak var Button8: UIButton!
    @IBOutlet weak var Button9: UIButton!

    @IBOutlet weak var Player1Score: UILabel!
    @IBOutlet weak var Player2Score: UILabel!
    @IBOutlet weak var DrawScore: UILabel!
    @IBOutlet weak var TurnIndicator: UILabel!
    
    var buttons: [Int: UIButton] = [:]
    var scoreLabels: [Int: UILabel] = [:]

    let soundEffect = URL(fileURLWithPath: Bundle.main.path(forResource: "oof", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonOnClick(_ sender: UIButton) {
        if (sender.titleLabel?.text != nil && self.game.currentTurn != self.mark) {
            return;
        }
        self.socketManager.socket.emit("movement", sender.tag)
    }

    func initEventListeners() {
        self.socketManager.socket.on("movement") {data, ack in
            let json: Movement = Movement(data[0] as! [String : Any])
            if (json.err == nil) {
                self.buttons[json.index!]?.setTitle(json.player_played!.uppercased(), for: .normal)
                self.game.currentTurn = json.player_play!
                if (json.win == true) {
                    self.handleWin(player: json.player_played!)
                }
                if (self.checkDraw()) {
                    self.handleDraw()
                }
                self.setTurn()
            }
        }
    }

    func resetGrid() {
        (0...8).forEach {button in
            self.buttons[button]?.setTitleColor(UIColor.black, for: .normal)
        }
        for (_, button) in self.buttons {
            button.setTitle("", for: .normal)
        }
    }
    
    func checkDraw() -> Bool {
        var count: Int = 0
        for (_, button) in self.buttons {
            if (button.titleLabel?.text != nil) {
                count += 1
            }
        }

        return count == 9
    }

    func handleWin(player: String) {
        self.shout()
        let alert = UIAlertController(
            title: "",
            message: self.mark == player ? "Victoire !" : "Défaite !",
            preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: self.resetGrid)
        })
        alert.addAction(OKAction)
        
        return self.present(alert, animated: true)
    }

    func handleDraw() {
        self.shout()
        let alert = UIAlertController(
            title: "",
            message: "DRAW !",
            preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: self.resetGrid)
        })
        alert.addAction(OKAction)
        
        return self.present(alert, animated: true)
    }
    
    func shout() {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: self.soundEffect)
            self.audioPlayer.play()
        } catch {
            print("couldn't load the file :(")
        }
    }
}
