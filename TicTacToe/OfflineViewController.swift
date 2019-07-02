//
//  OfflineViewController.swift
//  TicTacToe
//
//  Created by Neil Richter on 18/06/2019.
//  Copyright © 2019 Neil Richter. All rights reserved.
//

import UIKit
import AVFoundation

class OfflineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttons = [
            1: self.Button1,
            2: self.Button2,
            3: self.Button3,
            4: self.Button4,
            5: self.Button5,
            6: self.Button6,
            7: self.Button7,
            8: self.Button8,
            9: self.Button9,
        ]

        self.scoreLabels = [
            0: self.DrawScore,
            1: self.Player1Score,
            2: self.Player2Score,
        ]

        if let retrievedDict = UserDefaults.standard.dictionary(forKey: "scores") {
            self.scores = retrievedDict as! [String: Int]
        }

        self.resetGrid()
        self.TurnIndicator.text = "Player \(self.turn)'s turn ! (\(self.mark[self.turn]!))"

        for (index, playerScore) in self.scoreLabels {
            let score: String = String(self.scores[String(index)]!)
            let text: String = index == 0 ? "Draws: \(score)" : "Player \(index): \(score)"
            playerScore.text = text
        }
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

    let mark: [Int: String] = [
        1: "X",
        2: "O",
    ]

    var scores: [String: Int] = [
        "0": 0,
        "1": 0,
        "2": 0,
    ]
    var turn: Int = 1

    var state: [Int: Int] = [:]

    let conditions: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9],
        [1, 5, 9],
        [3, 5, 7],
    ]

    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonOnClick(_ sender: UIButton) {
        if (state[sender.tag] != nil) {
            return;
        }

        state[sender.tag] = self.turn
        sender.setTitle(self.mark[self.turn], for: .normal)

        if (self.hasWon(turn: turn) == true) {
            return self.handleWin(player: turn)
        }
        if (self.checkDraw() == true) {
            return self.handleWin(player: 0)
        }
        self.nextTurn()
    }

    func nextTurn() {
        self.turn = self.turn == 1 ? 2 : 1
        self.TurnIndicator.text = "Player \(self.turn)'s turn ! (\(self.mark[self.turn]!))"
    }

    func hasWon(turn: Int) -> Bool {
        var won: Bool

        for set in self.conditions {
            let values: [Int] = set.map({ self.state[$0] ?? 0 })

            won = values.allSatisfy({ $0 == turn})
            if (won == true) {
                self.colorizeWonRow(values: set)
                return true;
            }
        }
        return false
    }

    func checkDraw() -> Bool {
        return self.state.count == 9
    }

    func resetGrid() {
        self.turn = Int.random(in: 1...2)
        (1...9).forEach {button in
                self.buttons[button]?.setTitleColor(UIColor.black, for: .normal)
        }
        self.state = [:]
        for (_, button) in self.buttons {
            button.setTitle("", for: .normal)
        }
    }

    func handleWin(player: Int) {
        self.shout()
        let text: String = [1, 2].contains(player) ? "Player \(self.turn) won !" : "Draw !"
        self.log(text: text)
        let alert = UIAlertController(
            title: "",
            message: text,
            preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetGrid()
            self.addPoint(player: player)
        })
        alert.addAction(OKAction)

        return self.present(alert, animated: true)
    }

    func colorizeWonRow(values: [Int]) {
        values.forEach {button in
            self.buttons[button]?.setTitleColor(UIColor.green, for: .normal)
        }
    }

    func addPoint(player: Int) {
        self.scores[String(player)]! += 1
        var text: String = ""
        text = [1, 2].contains(player) ? "Player \(player)" : "Draws"
        self.scoreLabels[player]!.text = text + ": \(self.scores[String(player)]!)"
        self.updateStorage()
    }

    func updateStorage() {
        UserDefaults.standard.set(self.scores, forKey: "scores")
    }

    func log(text: String) {
        var retrievedLogs: [String] = UserDefaults.standard.array(forKey: "logs") as? [String] ?? [] as! [String]
        retrievedLogs.append(text)
        print(retrievedLogs)
        UserDefaults.standard.set(retrievedLogs, forKey: "logs")
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
