//
//  FinishedProfileViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

var userFriends = [String]()
var loveStoryCelebrators = [String]()

class FinishedProfileViewController: UIViewController {

    //Variables
    var profileLbl: UILabel?
    var profileImage: UIImageView?
    var nameLbl: UILabel?
    var editProfileBtn: UIButton?
    var notificationsBtn: UIButton?
    var messagesBtn: UIButton?
    var lineInset: UILabel?
    var createBtn: UIButton?
    var orLbl: UILabel?
    var joinBtn: UIButton?
    var loverPageLbl: UILabel?
    var infoLbl1: UILabel?
    var infoLbl2: UILabel?
    var searchUsersBtn: UIButton?
    
    var width = UIScreen.main.bounds.width
    
    //Outlets
    
    
    //Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserDataFromFirebase()
        setupUI()

    }
    
    
    func setupUI(){
        profileLbl = UILabel(frame: CGRect(x: self.view.frame.midX - width/5.8, y: width/8, width: width/2.9, height: width/16))
        profileLbl?.text = "Profile"
        profileLbl?.textAlignment = .center
        profileLbl?.font = UIFont(name: "Avenir Next", size: 20)
        view.addSubview(profileLbl!)
        
        profileImage = UIImageView(frame: CGRect(x: self.view.frame.midX - width/5.8, y: (profileLbl?.frame.origin.y)! + width/4.57, width: width/2.9, height: width/2.9))
        profileImage?.contentMode = .scaleAspectFill
        profileImage?.layer.cornerRadius = (profileImage?.frame.size.width)!/2
        profileImage?.clipsToBounds = true
        view.addSubview(profileImage!)
        
        nameLbl = UILabel(frame: CGRect(x: self.view.frame.midX - width/3.2, y: (profileImage?.frame.origin.y)! + width/2.9 + width/32, width: width/1.6, height: width/12.8))
        nameLbl?.textAlignment = .center
        nameLbl?.font = UIFont(name: "Avenir Next", size: 20)
        nameLbl?.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(nameLbl!)
        
        editProfileBtn = UIButton(frame: CGRect(x: self.view.frame.midX - width/5.32, y: (nameLbl?.frame.origin.y)! + width/12.8 + width/64, width: width/2.66, height: width/12.8))
        editProfileBtn?.setTitle("Edit Profile", for: .normal)
        editProfileBtn?.setTitleColor(.black, for: .normal)
        editProfileBtn?.titleLabel?.font = UIFont(name: "Avenir Next", size: 13)
        editProfileBtn?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        editProfileBtn?.layer.borderColor = UIColor.black.cgColor
        editProfileBtn?.layer.borderWidth = 1
        editProfileBtn?.layer.cornerRadius = (editProfileBtn?.frame.size.height)!/2
        editProfileBtn?.clipsToBounds = true
        view.addSubview(editProfileBtn!)
        
        notificationsBtn = UIButton(frame: CGRect(x: width/10.67, y: (editProfileBtn?.frame.origin.y)! + (editProfileBtn?.frame.size.height)! + width/64, width: width/9.14, height: width/9.14))
        notificationsBtn?.setImage(#imageLiteral(resourceName: "notifications"), for: .normal)
        view.addSubview(notificationsBtn!)
        
        messagesBtn = UIButton(frame: CGRect(x: width - width/10.67 - width/9.14, y: (editProfileBtn?.frame.origin.y)! + (editProfileBtn?.frame.size.height)! + width/64, width: width/9.14, height: width/9.14))
        messagesBtn?.setImage(#imageLiteral(resourceName: "messages"), for: .normal)
        messagesBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMessage)))
        view.addSubview(messagesBtn!)
        
        lineInset = UILabel(frame: CGRect(x: width/20, y: (notificationsBtn?.frame.origin.y)! + width/9.14 + width/6.33, width: width - width/10, height: width/320))
        lineInset?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.addSubview(lineInset!)
        
        searchUsersBtn = UIButton(frame: CGRect(x: width/40, y: width/20, width: width/10.66, height: width/10.66))
        searchUsersBtn?.setImage(#imageLiteral(resourceName: "searchIcon"), for: .normal)
        searchUsersBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSearchUsers)))
        view.addSubview(searchUsersBtn!)
        
    }
    
    func handleMessage(gesture: UITapGestureRecognizer){
        performSegue(withIdentifier: "messages", sender: nil)
        
    }
    
    func handleSearchUsers(gesture: UITapGestureRecognizer){
        performSegue(withIdentifier: "test", sender: nil)
    }
    
    func getUserDataFromFirebase(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User()
                user.birthday = dictionary["birthday"] as! NSNumber
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.gender = dictionary["gender"] as? String
                
                self.nameLbl?.text = user.name
                self.profileImage?.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
                
                
            }
        })
    }
    
    

}
