//
//  ViewController.swift
//  SampleWebSocket
//
//  Created by Ravikiran Pathade on 7/27/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(textField.text!)
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
    @IBOutlet weak var typingLabel: UITextField!
    
    @IBOutlet weak var chatTexts: UITextView!
    
    deinit {
        socket.disconnect()
        socket.delegate = nil
    }
    
  var socket = WebSocket(url: URL(string: "ws://localhost:1337/")!, protocols: ["chat"])
    
  func websocketDidConnect(socket: WebSocketClient) {
        socket.write(string: username!)
        chatTexts.isHidden = false
 
    }
    func sendMessage(_ message: String){
        socket.write(string: message)
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        chatTexts.isHidden = true
        print("Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let messageType = jsonDict["type"] as? String else {
                return
        }
        
        if messageType == "message",
            let messageData = jsonDict["data"] as? [String: Any],
            let messageAuthor = messageData["author"] as? String,
            let messageText = messageData["text"] as? String {
            chatTexts.text = chatTexts.text + "\n" + messageAuthor + " : " + messageText
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "Enter Your Name", message: "The name will be used while chatting.", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            self.username = alert.textFields![0].text
            self.chatTexts.text = "\n YOU ARE CHATTING AS :" + self.username!
            self.socket.connect()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
  
        
        chatTexts.isHidden = true
        socket.delegate = self
        typingLabel.delegate = self
        

    }
    var username : String?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

