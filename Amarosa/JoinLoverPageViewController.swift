//
//  JoinLoverPageViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

class JoinLoverPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var backBtn: UIButton?
    var joinLbl: UILabel?
    var searchLblBackGround: UILabel?
    var searchIconImageView: UIImageView?
    var searchTxt: UITextField?
    var users = [User]()
    var filteredUsers = [User]()
    var tableView: UITableView?
    var enterPassCodeLbl: UILabel?
    var passcodeTxt: UITextField?
    var loverPageImageView: UIImageView?
    var createrImage: UIImageView?
    var joinerImage: UIImageView?
    var completeUserNameLbl: UILabel?
    var userNameLblFirst: UITextField?
    var userNameLblSecond: UITextField?
    var infoLbl1: UILabel?
    var infoLbl2: UILabel?
    var infoLbl3: UILabel?
    var doneBtn: UIButton?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var loverStoryId: String?
    var loverPage: LoverStoryPage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        observeAllUsers()
    }
    
    func setupUI(){
        backBtn = UIButton(frame: CGRect(x: width/80, y: width/20, width: width/7.27, height: width/7.27))
        backBtn?.setImage(#imageLiteral(resourceName: "Back arrow"), for: .normal)
        backBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        view.addSubview(backBtn!)
        
        joinLbl = UILabel(frame: CGRect(x: 0, y: width/9, width: width, height: width/11))
        joinLbl?.text = "Join Loverpage"
        joinLbl?.font = UIFont(name: "Avenir Next", size: width/12.8)
        joinLbl?.textAlignment = .center
        joinLbl?.font = UIFont.boldSystemFont(ofSize: width/12.8)
        view.addSubview(joinLbl!)
        
        searchLblBackGround = UILabel(frame: CGRect(x: width/20, y: (joinLbl?.frame.origin.y)! + (joinLbl?.frame.size.height)! + width/16, width: width/8, height: width/10.67))
        searchLblBackGround?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        searchLblBackGround?.layer.cornerRadius = width/64
        searchLblBackGround?.layer.zPosition = 3
        searchLblBackGround?.layer.masksToBounds = true
        view.addSubview(searchLblBackGround!)
        
        searchIconImageView = UIImageView(frame: CGRect(x: width/10.67, y: (joinLbl?.frame.origin.y)! + (joinLbl?.frame.size.height)! + width/16 + width/48, width: width/24, height: width/24))
        searchIconImageView?.image = #imageLiteral(resourceName: "searchIcon")
        searchIconImageView?.layer.zPosition = 4
        searchIconImageView?.layer.masksToBounds = true
        view.addSubview(searchIconImageView!)
        
        searchTxt = UITextField(frame: CGRect(x: (searchLblBackGround?.frame.origin.x)! + (searchLblBackGround?.frame.size.width)! - width/64, y: (joinLbl?.frame.origin.y)! + (joinLbl?.frame.size.height)! + width/16, width: width -  (searchLblBackGround?.frame.origin.x)! - (searchLblBackGround?.frame.size.width)! + width/64 - width/20, height: width/10.67))
        searchTxt?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        searchTxt?.font = UIFont(name: "Avenir Next", size: 17)
        searchTxt?.placeholder = "Search Users"
        searchTxt?.layer.cornerRadius = width/64
        searchTxt?.clearButtonMode = .always
        searchTxt?.layer.zPosition = 3
        searchTxt?.layer.masksToBounds = true
        view.addSubview(searchTxt!)
        
        tableView = UITableView(frame: CGRect(x: width/20, y: (searchLblBackGround?.frame.origin.y)! + (searchLblBackGround?.frame.size.height)!, width: width - width/10, height: width/1.6))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(searchedUserCell.self, forCellReuseIdentifier: "cell")
        tableView?.layer.cornerRadius = width/64
        tableView?.layer.masksToBounds = true
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        view.addSubview(tableView!)
        
        enterPassCodeLbl = UILabel(frame: CGRect(x: 0, y: (tableView?.frame.origin.y)! + (tableView?.frame.size.height)! + width/8, width: width, height: width/11))
        enterPassCodeLbl?.text = "Enter Passcode"
        enterPassCodeLbl?.font = UIFont(name: "Avenir Next", size: width/16)
        enterPassCodeLbl?.textAlignment = .center
        view.addSubview(enterPassCodeLbl!)
        
        passcodeTxt = UITextField(frame: CGRect(x: self.view.frame.midX - width/6.4, y: (enterPassCodeLbl?.frame.origin.y)! + (enterPassCodeLbl?.frame.size.height)! + width/128, width: width/3.2, height: width/9))
        passcodeTxt?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        passcodeTxt?.font = UIFont(name: "Avenir Next", size: width/18)
        passcodeTxt?.layer.cornerRadius = width/32
        passcodeTxt?.returnKeyType = .done
        passcodeTxt?.delegate = self
        view.addSubview(passcodeTxt!)
        
        loverPageImageView = UIImageView(frame: CGRect(x: self.view.frame.midX - width/5, y: (joinLbl?.frame.origin.y)! + (joinLbl?.frame.size.height)! + width/8, width: width/2.5, height: width/5))
        loverPageImageView?.layer.cornerRadius = width/64
        loverPageImageView?.layer.masksToBounds = true
        loverPageImageView?.contentMode = .scaleAspectFill
        view.addSubview(loverPageImageView!)
        
        createrImage = UIImageView(frame: CGRect(x: (loverPageImageView?.frame.origin.x)!, y: (loverPageImageView?.frame.origin.y)! + (loverPageImageView?.frame.size.height)! + width/64, width: width/9.14, height: width/9.14))
        createrImage?.layer.cornerRadius = (createrImage?.frame.size.width)!/2
        createrImage?.layer.masksToBounds = true
        view.addSubview(createrImage!)
        
        joinerImage = UIImageView(frame: CGRect(x: (loverPageImageView?.frame.origin.x)! + (loverPageImageView?.frame.size.width)! - width/9.14, y: (loverPageImageView?.frame.origin.y)! + (loverPageImageView?.frame.size.height)! + width/64, width: width/9.14, height: width/9.14))
        joinerImage?.layer.cornerRadius = (joinerImage?.frame.size.width)!/2
        joinerImage?.layer.masksToBounds = true
        view.addSubview(joinerImage!)
        
        completeUserNameLbl = UILabel(frame: CGRect(x: 0, y: (createrImage?.frame.origin.y)! + (createrImage?.frame.size.height)! + width/8, width: width, height: width/11))
        completeUserNameLbl?.text = "Complete Username"
        completeUserNameLbl?.textAlignment = .center
        completeUserNameLbl?.font = UIFont(name: "Avenir Next", size: width/16)
        view.addSubview(completeUserNameLbl!)
        
        userNameLblFirst = UITextField(frame: CGRect(x: self.view.frame.midX - width/2.7, y: (completeUserNameLbl?.frame.origin.y)! + (completeUserNameLbl?.frame.size.height)! + width/32, width: width/2.4, height: width/9))
        userNameLblFirst?.backgroundColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1)
        userNameLblFirst?.font = UIFont(name: "Avenir Next", size: width/18)
        userNameLblFirst?.layer.cornerRadius = width/32
        userNameLblFirst?.textColor = .white    
        userNameLblFirst?.isUserInteractionEnabled = false
        view.addSubview(userNameLblFirst!)
        
        userNameLblSecond = UITextField(frame: CGRect(x: self.view.frame.midX, y: (completeUserNameLbl?.frame.origin.y)! + (completeUserNameLbl?.frame.size.height)! + width/32, width: width/2.4, height: width/9))
        userNameLblSecond?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        userNameLblSecond?.layer.cornerRadius = width/32
        userNameLblSecond?.layer.zPosition = 3
        userNameLblSecond?.layer.masksToBounds = true
        userNameLblSecond?.placeholder = "Username"
        userNameLblSecond?.font = UIFont(name: "Avenir Next", size: width/18)
        view.addSubview(userNameLblSecond!)
        
        infoLbl1 = UILabel(frame: CGRect(x: 0, y: (userNameLblFirst?.frame.origin.y)! + (userNameLblFirst?.frame.size.height)! + width/32, width: width, height: width/21.3))
        infoLbl1?.textAlignment = .center
        infoLbl1?.text = "Your partner create the first half of the username."
        infoLbl1?.font = UIFont(name: "Avenir Next", size: 12)
        infoLbl1?.textColor = UIColor.lightGray
        view.addSubview(infoLbl1!)
        
        infoLbl2 = UILabel(frame: CGRect(x: 0, y: (infoLbl1?.frame.origin.y)! + (infoLbl1?.frame.size.height)! + 1  , width: width, height: width/21.3))
        infoLbl2?.textAlignment = .center
        infoLbl2?.text = "Now you can complete the second,"
        infoLbl2?.font = UIFont(name: "Avenir Next", size: 12)
        infoLbl2?.textColor = UIColor.lightGray
        view.addSubview(infoLbl2!)
        
        infoLbl3 = UILabel(frame: CGRect(x: 0, y: (infoLbl2?.frame.origin.y)! + (infoLbl2?.frame.size.height)! + 1  , width: width, height: width/21.3))
        infoLbl3?.textAlignment = .center
        infoLbl3?.text = "the two halves will make up the full username!"
        infoLbl3?.font = UIFont(name: "Avenir Next", size: 12)
        infoLbl3?.textColor = UIColor.lightGray
        view.addSubview(infoLbl3!)
        
        doneBtn = UIButton(frame: CGRect(x: self.view.frame.midX - width/3.2, y: height - width/9 - width/20, width: width/1.6, height: width/9))
        doneBtn?.setTitle("Done", for: .normal)
        doneBtn?.setTitleColor(UIColor(red: 0.6, green: 0.58, blue: 0.98, alpha: 1), for: .normal)
        doneBtn?.titleLabel?.font = UIFont(name: "Avenir Next", size: 15)
        doneBtn?.layer.borderColor = UIColor(red: 0.6, green: 0.58, blue: 0.98, alpha: 1).cgColor
        doneBtn?.layer.borderWidth = 1
        doneBtn?.layer.cornerRadius = (doneBtn?.frame.size.height)!/2
        doneBtn?.layer.masksToBounds = true
        doneBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostJoinedLoverPage)))
        view.addSubview(doneBtn!)
        
        userNameLblFirst?.isHidden = true
        userNameLblSecond?.isHidden = true
        infoLbl1?.isHidden = true
        infoLbl2?.isHidden = true
        infoLbl3?.isHidden = true
        completeUserNameLbl?.isHidden = true
        createrImage?.isHidden = true
        joinerImage?.isHidden = true
        passcodeTxt?.isHidden = true
        enterPassCodeLbl?.isHidden = true
        loverPageImageView?.isHidden = true
        doneBtn?.isHidden = true
        
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleSearchFirebase), userInfo: nil, repeats: true)
    }
    
    func handlePostJoinedLoverPage(gesture: UITapGestureRecognizer){
        if userNameLblSecond?.text == ""{
            myAlert(title: "Enter Username", message: "Please enter the second half of the username")
        }else{
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            
            let newUsername = (loverPage?.username)! + (userNameLblSecond?.text)!
            loverPage?.lovers?.append(uid)
            
            if let loveStory = loverStoryId{
        Database.database().reference().child("loverProfiles").child(loverStoryId!).updateChildValues(["lovers":loverPage?.lovers, "username":newUsername], withCompletionBlock: { (error, ref) in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                print("join success")
            })
                
                Database.database().reference().child("users").child(uid).updateChildValues(["lovePage":loverStoryId!], withCompletionBlock: { (error, ref) in
                    if let err = error{
                        print(err.localizedDescription)
                        return
                    }
                    print("saved to user db")
                    self.performSegue(withIdentifier: "camera3", sender: nil)
                })
                
        }

            
            
    }
    }
    
    func handleBack(gesture: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
    
    func handleSearchFirebase(){

         tableView?.frame.size.height = CGFloat(filteredUsers.count) * width/4.923
         enterPassCodeLbl?.frame = CGRect(x: 0, y: (tableView?.frame.origin.y)! + (tableView?.frame.size.height)! + width/8, width: width, height: width/11)
        passcodeTxt?.frame = CGRect(x: self.view.frame.midX - width/6.4, y: (enterPassCodeLbl?.frame.origin.y)! + (enterPassCodeLbl?.frame.size.height)! + width/128, width: width/3.2, height: width/9)
        
        filteredUsers.removeAll()
        for user in users {
            if let searchText = searchTxt?.text{
                if (user.name?.lowercased().contains(searchText.lowercased()))!{
                    filteredUsers.append(user)
                }
            }
        }
       tableView?.reloadData()
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
                        
                        self.users.append(user)
                    }
                }
            }
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! searchedUserCell
        cell.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        cell.selectionStyle = .none
        let user = filteredUsers[indexPath.row]
        cell.myImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
        cell.myImageView.layer.cornerRadius = cell.myImageView.frame.size.width/2
        cell.myImageView.layer.masksToBounds = true
        cell.searchedTextLabel.text = user.name
        cell.layer.cornerRadius = width/64
        cell.layer.masksToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = filteredUsers[indexPath.row]
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        loverStoryId = user.loverStoryID
        
        if user.loverStoryID == "" || user.loverStoryID == nil{
            myAlert(title: "No Loverpage Created", message: "This user has not yet created a lover page")
            passcodeTxt?.isHidden = true
            enterPassCodeLbl?.isHidden = true
            loverPageImageView?.isHidden = true
            createrImage?.isHidden = true
            joinerImage?.isHidden = true
            
            loverStoryId = ""
            self.loverPage = LoverStoryPage()
            self.loverPage?.loverPageImageUrl = ""
            self.loverPage?.lovers = []
            self.loverPage?.password = ""
            self.loverPage?.username = ""
            self.loverStoryId = user.loverStoryID
        }else{
            Database.database().reference().child("loverProfiles").child(user.loverStoryID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    self.loverPage = LoverStoryPage()
                    self.loverPage?.loverPageImageUrl = dictionary["lovePageurl"] as? String
                    self.loverPage?.lovers = dictionary["lovers"] as? [String]
                    self.loverPage?.password = dictionary["password"] as? String
                    self.loverPage?.username = dictionary["username"] as? String
                    
                    self.loverPageImageView?.loadImageUsingCacheWithUrlString(urlString: (self.loverPage?.loverPageImageUrl)!)
                    self.createrImage?.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
                    self.userNameLblFirst?.text = self.loverPage?.username
                    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String:AnyObject]{
                            var url = dictionary["profileImageUrl"] as? String
                            self.joinerImage?.loadImageUsingCacheWithUrlString(urlString: url!)
                        }
                    })
                    
                }
            })

            passcodeTxt?.isHidden = false
            enterPassCodeLbl?.isHidden = false
          

        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return width/4.923
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
       
        if textField.text == self.loverPage?.password{
            tableView?.isHidden = true
            searchTxt?.isHidden = true
            searchIconImageView?.isHidden = true
            searchLblBackGround?.isHidden = true
            enterPassCodeLbl?.isHidden = true
            passcodeTxt?.isHidden = true
            loverPageImageView?.isHidden = false
            createrImage?.isHidden = false
            joinerImage?.isHidden = false
            completeUserNameLbl?.isHidden = false
            userNameLblFirst?.isHidden = false
            userNameLblSecond?.isHidden = false
            infoLbl1?.isHidden = false
            infoLbl2?.isHidden = false
            infoLbl3?.isHidden = false
            doneBtn?.isHidden = false

        }else{
            myAlert(title: "Wrong Passcode", message: "Please enter the correct passcode for the lover page")
        }
        
        
        return true
    }
    
    func myAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
}

