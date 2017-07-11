//
//  NewMessageViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//
import UIKit
import Firebase


var chosenUser = User()

class NewMessageViewController: UITableViewController {
    
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        navigationItem.title = "Compose"
        
        fetchUser()
        
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.uid = snapshot.key
                //if use this setter app will crash is class properties dont exactly match up with actual fb keys
                //safer user.name = dictionary["name"]
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.users.append(user)
                
                //this will crash because of background thread so use dispatch_async
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
            
        })
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUser = users[indexPath.row]
        performSegue(withIdentifier: "chatLog", sender: nil)
    }
    
    
}
