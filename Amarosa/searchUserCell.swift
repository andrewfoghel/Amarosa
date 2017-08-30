//
//  searchUserCell.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/18/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit

class searchedUserCell: UITableViewCell{
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
    
    var searchedImageView: UIImageView?
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = CGRect(x: width/20, y: width/32, width: width/7.11, height: width/7.11)
        
        searchedTextLabel.frame = CGRect(x: myImageView.frame.origin.x + myImageView.frame.size.width + width/64, y: width/14.22, width: self.frame.width - myImageView.frame.origin.x + myImageView.frame.size.width + width/64 , height: width/16)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(searchedTextLabel)
        addSubview(myImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
