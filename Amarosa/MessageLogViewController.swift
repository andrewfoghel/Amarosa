//
//  MessageLogViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

class MessageLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var messages = [Message]()
    var messagesDictionary = [String:Message]()

    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // declare hide kyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        myTableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        myTableView.allowsMultipleSelectionDuringEditing = true
        
        messages.removeAll()
        messagesDictionary.removeAll()
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        observeUserMessages()
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId(){
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                
                if let err = error{
                    print("failed to delete",err.localizedDescription)
                    return
                }
                
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
                //    self.messages.remove(at: indexPath.row)
                //    self.myTableView.deleteRows(at: [indexPath], with: .automatic)
                
                
            })
            
        }
        
        
    }
    
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
                
                
            })
        })
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        })
        
    }
    
    var timer: Timer?
    
    func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (myMessage1, myMessage2) -> Bool in
            return Int((myMessage1.timeStamp?.int64Value)!) > Int((myMessage2.timeStamp?.int64Value)!)
        })
        
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
    
    
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(dictionary: dictionary)
                if let chatPartnerId = message.chatPartnerId(){
                    self.messagesDictionary[chatPartnerId] = message
                }
                //delay for weird loading
                
                self.attemptReloadOfTable()
                
                
            }
            
            
        })
    }
    
    
    func observeGroupMessages(){
        
    }
    
    
    
    
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.message = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        let chatPartnerId: String?
        if message.fromId == Auth.auth().currentUser?.uid{
            chatPartnerId = message.toId
        }else{
            chatPartnerId = message.fromId
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                return
            }
            let user = User()
            user.uid = chatPartnerId
            user.setValuesForKeys(dictionary)
            chosenUser = user
            self.performSegue(withIdentifier: "chatLog1", sender: nil)
        })
        
        
        
    }
    
    
    func handleBackToFeed(){
        dismiss(animated: true, completion: nil)
    }
    
    /*   func handleLogout(){
     do {
     try FIRAuth.auth()?.signOut()
     performSegue(withIdentifier: "loginForgot", sender: nil)
     } catch let logoutError {
     print("unable to logout successfully",logoutError)
     }
     } */
    
    
    func handleNewMessage(){
        performSegue(withIdentifier: "newMessage", sender: nil)
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
}
