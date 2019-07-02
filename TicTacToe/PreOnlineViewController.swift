//
//  PreOnlineViewController.swift
//  TicTacToe
//
//  Created by Neil Richter on 28/06/2019.
//  Copyright © 2019 Neil Richter. All rights reserved.
//

import UIKit
import RLBAlertsPickers

class PreOnlineViewController: UIViewController {
    
    let socketHandler = SocketHandler.shared
    var searching: Bool = false
    var username: String = ""
    var socketData: JoinGame!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socketHandler.socket.on("join_game") { data, ack in
            if (self.searching == true) {
                let json = data[0] as! [String: Any]
                self.socketData = JoinGame(
                    currentTurn: json["currentTurn"] as! String,
                    playerO: json["playerO"] as! String,
                    playerX: json["playerX"] as! String
                )
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "OnlineGameStart", sender: nil)
            }
        }
    }
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBAction func SearchPlayerButton(_ sender: UIButton) {
        let alert = UIAlertController(style: .alert, title: "Nom")
        
        let configOne: TextField.Config = { textField in
            textField.leftViewPadding = 16
            textField.leftTextPadding = 12
            textField.becomeFirstResponder()
            textField.backgroundColor = nil
            textField.textColor = .black
            textField.placeholder = "Votre nom"
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.action { textField in
                self.username = textField.text!
            }
        }
        alert.addOneTextField(configuration: configOne)
        alert.addAction(title: "OK", style: .cancel) { action in
            let alert2 = UIAlertController(title: nil, message: "Waiting for a player...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            alert2.view.addSubview(loadingIndicator)
            self.searching = true
            self.present(alert2, animated: true, completion: nil)
            self.socketHandler.socket.emit("join_queue", self.username)
        }
        alert.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "OnlineGameStart"){
            let vc = segue.destination as! OnlineViewController
            vc.game = self.socketData
            vc.player = self.username
        }
    }
}
