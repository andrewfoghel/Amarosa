//
//  NewMessageVC.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase


var chosenUser = User()

class NewMessageVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    var users = [User]()
    var inSearchMode = false
    var filteredUsers = [User]()
    
    
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        myTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
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
                self.users.append(user)
                //this will crash because of background thread so use dispatch_async
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
            }
            
            
        })
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //want to only display pokemon that only displays the pokemon we want to see
        
        
        if searchBar.text == nil || searchBar.text == ""{
            inSearchMode = false
            myTableView.reloadData()
            //make key board disappear
            view.endEditing(true)
        }else{
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            //the filtered pokemon is equal the orignal list but filtered $0 is place holder for any and all objects
            
            filteredUsers = users.filter{user in return (user.name?.lowercased().contains(lower))!}
            myTableView.reloadData()
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode == true{
            return filteredUsers.count
        }else{
            return users.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if inSearchMode{
            let user = filteredUsers[indexPath.row]
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            cell.selectionStyle = .none
        }else{
            let user = users[indexPath.row]
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            cell.selectionStyle = .none
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if inSearchMode{
            chosenUser = filteredUsers[indexPath.row]
        }else{
            chosenUser = users[indexPath.row]
        }
        
        
        performSegue(withIdentifier: "chatLog", sender: nil)
    }
    
    
}

