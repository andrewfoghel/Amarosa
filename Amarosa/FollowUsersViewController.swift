//
//  FollowUsersViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/18/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

class FollowUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var searchUsers = true
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func indexSwitched(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            searchUsers = true
            secondTableView?.removeFromSuperview()
            view.addSubview(tableView!)
            break
        case 1:
            searchUsers = false
            tableView?.removeFromSuperview()
            view.addSubview(secondTableView!)
        default:
            break
        }
    }
    
    
    var searchLblBackGround: UILabel?
    var searchIconImageView: UIImageView?
    var searchTxt: UITextField?
    var users = [User]()
    var filteredUsers = [User]()
    var lovePages = [LoverStoryPage]()
    var filteredLovePages = [LoverStoryPage]()
    var tableView: UITableView?
    var secondTableView: UITableView?
    var followUser = User()
    var backBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        observeAllUsers()
        observeFriends()
        observeCelebrators()
        observeAllLovePages()
        
         Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleSearchFirebase), userInfo: nil, repeats: true)
    }
    
    func setupUI(){
        backBtn = UIButton(frame: CGRect(x: width/80, y: width/20, width: width/7.27, height: width/7.27))
        backBtn?.setImage(#imageLiteral(resourceName: "Back arrow"), for: .normal)
        backBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        view.addSubview(backBtn!)
        
        segmentControl.frame = CGRect(x: width/20, y: width/9 + width/16, width: width - width/10, height: width/10.67)
        
        searchLblBackGround = UILabel(frame: CGRect(x: width/20, y: width/9 + width/16 + width/10.67 + width/40, width: width/8, height: width/10.67))
        searchLblBackGround?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        searchLblBackGround?.layer.cornerRadius = width/64
        searchLblBackGround?.layer.zPosition = 3
        searchLblBackGround?.layer.masksToBounds = true
        view.addSubview(searchLblBackGround!)
        
        searchIconImageView = UIImageView(frame: CGRect(x: width/10.67, y: width/9 + width/16 + width/48 + width/10.67 + width/40, width: width/24, height: width/24))
        searchIconImageView?.image = #imageLiteral(resourceName: "searchIcon")
        searchIconImageView?.layer.zPosition = 4
        searchIconImageView?.layer.masksToBounds = true
        view.addSubview(searchIconImageView!)
        
        searchTxt = UITextField(frame: CGRect(x: (searchLblBackGround?.frame.origin.x)! + (searchLblBackGround?.frame.size.width)! - width/64, y: width/9 + width/16 + width/10.67 + width/40, width: width - (searchLblBackGround?.frame.origin.x)! - (searchLblBackGround?.frame.size.width)! + width/64 - width/20, height: width/10.67))
        searchTxt?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        searchTxt?.font = UIFont(name: "Avenir Next", size: 17)
        searchTxt?.placeholder = "Search Users"
        searchTxt?.layer.cornerRadius = width/64
        searchTxt?.clearButtonMode = .always
        searchTxt?.layer.zPosition = 3
        searchTxt?.layer.masksToBounds = true
        view.addSubview(searchTxt!)
        
        tableView = UITableView(frame: CGRect(x: width/20, y: (searchLblBackGround?.frame.origin.y)! + (searchLblBackGround?.frame.size.height)!, width: width - width/10, height: height))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(FollowCell.self, forCellReuseIdentifier: "cell")
        tableView?.layer.cornerRadius = width/64
        tableView?.layer.masksToBounds = true
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        view.addSubview(tableView!)
        
        secondTableView = UITableView(frame: CGRect(x: width/20, y: (searchLblBackGround?.frame.origin.y)! + (searchLblBackGround?.frame.size.height)!, width: width - width/10, height: height))
        secondTableView?.delegate = self
        secondTableView?.dataSource = self
        secondTableView?.register(LoveStoryCell.self, forCellReuseIdentifier: "cell1")
        secondTableView?.layer.cornerRadius = width/64
        secondTableView?.layer.masksToBounds = true
        secondTableView?.separatorStyle = .none
        secondTableView?.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)

    }

    func handleSearchFirebase(){
        if searchUsers == true{
        tableView?.frame.size.height = CGFloat(filteredUsers.count) * width/4.923
        filteredUsers.removeAll()
        for user in users {
            if let searchText = searchTxt?.text{
                if user.name?.lowercased() == searchText.lowercased(){
                    filteredUsers.append(user)
                    }
                }
            }
            tableView?.reloadData()
        }else{
            secondTableView?.frame.size.height = CGFloat(filteredLovePages.count) * width/4.923
            filteredLovePages.removeAll()
            for lovePage in lovePages {
                if let searchText = searchTxt?.text{
                    if (lovePage.username?.lowercased().contains(searchText.lowercased()))!{
                        filteredLovePages.append(lovePage)
                    }
                }
            }
            secondTableView?.reloadData()
        }
    }
    
    func observeAllUsers(){
        Database.database().reference().child("users").observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.users.removeAll()
                for snap in snapshot{
                    if let dictionary = snap.value as? [String:AnyObject]{
                        let user = User()
                        user.name = dictionary["name"] as? String
                        user.email = dictionary["email"] as? String
                        user.gender = dictionary["gender"] as? String
                        user.birthday = dictionary["birthday"] as? NSNumber
                        user.profileImageUrl = dictionary["profileImageUrl"] as? String
                        user.loverStoryID = dictionary["lovePage"] as? String
                        user.uid = snap.key
                        self.users.append(user)
                    }
                }
            }
        })
    }
    
    func observeAllLovePages(){
        Database.database().reference().child("loverProfiles").observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.lovePages.removeAll()
                for snap in snapshot{
                    if let dictionary = snap.value as? [String:AnyObject]{
                        let lovePage = LoverStoryPage()
                        lovePage.username = dictionary["username"] as? String
                        lovePage.lovers = dictionary["lovers"] as? [String]
                        lovePage.loverPageImageUrl = dictionary["lovePageurl"] as? String
                        lovePage.id = snap.key
                        self.lovePages.append(lovePage)
                    }
                }
            }
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchUsers == true{
            return filteredUsers.count
        }else{
            return filteredLovePages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchUsers == true{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FollowCell
        cell.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        cell.selectionStyle = .none
        let user = filteredUsers[indexPath.row]
    
        cell.myImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
        cell.myImageView.layer.cornerRadius = cell.myImageView.frame.size.width/2
        cell.myImageView.layer.masksToBounds = true
        cell.searchedTextLabel.text = user.name
        cell.cellUserId = user.uid
        
        if userFriends.contains(cell.cellUserId!){
            cell.friendFlag = true
            cell.followBtn.setTitle("Unfriend", for: .normal)
        }else{
            cell.friendFlag = false
            cell.followBtn.setTitle("Friend", for: .normal)
        }
        
        
        
        cell.layer.cornerRadius = width/64
        cell.layer.masksToBounds = true
        
        return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! LoveStoryCell
            cell.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
            cell.selectionStyle = .none
            let lovePage = filteredLovePages[indexPath.row]
            cell.cellLovePageUserId = lovePage.id
            cell.myImageView.loadImageUsingCacheWithUrlString(urlString: lovePage.loverPageImageUrl!)
            cell.myImageView.layer.cornerRadius = cell.myImageView.frame.size.width/2
            cell.myImageView.layer.masksToBounds = true
            cell.searchedTextLabel.text = lovePage.username
            
            if loveStoryCelebrators.contains(cell.cellLovePageUserId!){
                cell.celebrateFlag = true
                cell.celebrateBtn.setTitle("Leave", for: .normal)
            }else{
                cell.celebrateFlag = false
                cell.celebrateBtn.setTitle("Celebrate", for: .normal)
            }
            
            cell.layer.cornerRadius = width/64
            cell.layer.masksToBounds = true
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return width/4.923
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        followUser = user
    }
    
    func observeFriends(){
        if searchUsers == true{
        Database.database().reference().child("friends").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (snapshot) in
            userFriends.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    userFriends.append(snap.key)
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                }
            }
        })
        }

    }
    
    func observeCelebrators(){
        Database.database().reference().child("celebrators").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (snapshot) in
            loveStoryCelebrators.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    loveStoryCelebrators.append(snap.key)
                    DispatchQueue.main.async {
                        self.secondTableView?.reloadData()
                    }
                }
            }
        })
    }
    
    func handleBack(gesture: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
    
}


