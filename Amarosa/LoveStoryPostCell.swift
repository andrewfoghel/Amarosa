//
//  LoveStoryPostCell.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit

class LoveStoryPostCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "Andrew")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = width/32
        iv.layer.borderColor = UIColor.red.cgColor
        iv.layer.borderWidth = width/160
        iv.layer.masksToBounds = true

        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        addSubview(imageView)
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
    }
    
    
}
