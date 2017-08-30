//
//  LoveStoryCell.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/20/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase

class LoveStoryCell: UITableViewCell {

    var cellLovePageUserId: String?
    let uid = Auth.auth().currentUser?.uid
    var celebrateFlag: Bool?
    var cellCelebrators = [String]()
    
    var searchedTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: width/18.82)
        return label
    }()
    
    var myImageView: UIImageView = {
        let searchedImageView = UIImageView()
        searchedImageView.contentMode = .scaleAspectFill
        return searchedImageView
    }()
    
    var celebrateBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.black
        btn.titleLabel?.font = UIFont(name: "Avenir Next", size: 12)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    var searchedImageView: UIImageView?
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = CGRect(x: width/20, y: width/32, width: width/7.11, height: width/7.11)
        
        searchedTextLabel.frame = CGRect(x: myImageView.frame.origin.x + myImageView.frame.size.width + width/64, y: width/14.22, width: self.frame.width - myImageView.frame.origin.x + myImageView.frame.size.width + width/64 , height: width/16)
        
        celebrateBtn.frame = CGRect(x: width - width/20 - width/5.33 - width/12.5, y: width/17.5, width: width/5.33, height: width/10.67)
        celebrateBtn.layer.cornerRadius = celebrateBtn.frame.size.height/2
        celebrateBtn.layer.masksToBounds = true
        celebrateBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCelebrators)))
        
        
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(searchedTextLabel)
        addSubview(myImageView)
        addSubview(celebrateBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleCelebrators(gesture: UITapGestureRecognizer){
        print(celebrateFlag)
        
        
        if celebrateFlag == false{
            //Add Friend
            celebrateBtn.setTitle("Celebrate", for: .normal)
            Database.database().reference().child("celebrators").child(uid!).child(cellLovePageUserId!).setValue(1) { (error, ref) in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
            }
        }else{
            celebrateBtn.setTitle("Leave", for: .normal)
            Database.database().reference().child("celebrators").child(uid!).child(cellLovePageUserId!).removeValue()
            
        }
        
    }
    
}

