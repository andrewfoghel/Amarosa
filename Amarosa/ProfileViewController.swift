//
//  ProfileViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/13/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    //Variables
    var profileLbl: UILabel?
    var profileImage: UIImageView?
    var nameLbl: UILabel?
    var editProfileBtn: UIButton?
    var lineInset: UILabel?
    var createBtn: UIButton?
    var orLbl: UILabel?
    var joinBtn: UIButton?
    var loverPageLbl: UILabel?
    var infoLbl1: UILabel?
    var infoLbl2: UILabel?
    
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
        
        lineInset = UILabel(frame: CGRect(x: width/20, y: (editProfileBtn?.frame.origin.y)! + (editProfileBtn?.frame.size.height)! + width/64 + width/9.14 + width/6.33, width: width - width/10, height: width/320))
        lineInset?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.addSubview(lineInset!)
        
        createBtn = UIButton(frame: CGRect(x: width/10, y: (lineInset?.frame.origin.y)! + (lineInset?.frame.size.height)! + width/8, width: width/3, height: width/12.8))
        createBtn?.setTitle("Create", for: .normal)
        createBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCreateTap)))
        createBtn?.backgroundColor = UIColor(red: 0.99, green: 0.77, blue: 0.4, alpha: 1)
        createBtn?.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        createBtn?.layer.cornerRadius = (createBtn?.frame.size.height)!/2
        createBtn?.clipsToBounds = true
        view.addSubview(createBtn!)
        
        orLbl = UILabel(frame: CGRect(x: self.view.frame.midX - width/40, y: (createBtn?.frame.origin.y)! + width/80, width: width/20, height: width/20))
        orLbl?.text = "or"
        orLbl?.font = UIFont(name: "Avenir Next", size: 18)
        view.addSubview(orLbl!)
        
        joinBtn = UIButton(frame: CGRect(x: width - width/3 - width/10, y: (createBtn?.frame.origin.y)!, width: width/3, height: width/12.8))
        joinBtn?.setTitle("Join", for: .normal)
        joinBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleJoinTap)))
        joinBtn?.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        joinBtn?.backgroundColor = UIColor(red: 1, green: 0.28, blue: 0.28, alpha: 1)
        joinBtn?.layer.cornerRadius = (joinBtn?.frame.size.height)!/2
        joinBtn?.clipsToBounds = true
        view.addSubview(joinBtn!)
        
        loverPageLbl = UILabel(frame: CGRect(x: 0, y: (createBtn?.frame.origin.y)! + (createBtn?.frame.height)! + width/32, width: width, height: width/8))
        loverPageLbl?.text = "Your Loverpage"
        loverPageLbl?.font = UIFont(name: "Avenir Next", size: 25)
        loverPageLbl?.textAlignment = .center
        view.addSubview(loverPageLbl!)
        
        infoLbl1 = UILabel(frame: CGRect(x: 0, y: (loverPageLbl?.frame.origin.y)! + (loverPageLbl?.frame.size.height)! + width/16, width: width, height: width/21.3))
        infoLbl1?.textAlignment = .center
        infoLbl1?.text = "Make sure to create or join a Loverpage"
        infoLbl1?.font = UIFont(name: "Avenir Next", size: 13)
        infoLbl1?.textColor = UIColor.lightGray
        view.addSubview(infoLbl1!)

        infoLbl2 = UILabel(frame: CGRect(x: 0, y: (infoLbl1?.frame.origin.y)! + (infoLbl1?.frame.size.height)! + 2  , width: width, height: width/21.3))
        infoLbl2?.textAlignment = .center
        infoLbl2?.text = "with your partner to start posting on your Love Story"
        infoLbl2?.font = UIFont(name: "Avenir Next", size: 13)
        infoLbl2?.textColor = UIColor.lightGray
        view.addSubview(infoLbl2!)
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

    func handleCreateTap(gesture: UITapGestureRecognizer){
        performSegue(withIdentifier: "create", sender: nil)
    }
    
    func handleJoinTap(gesture: UITapGestureRecognizer){
        performSegue(withIdentifier: "join", sender: nil)
    }
    

}
