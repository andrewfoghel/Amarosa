//
//  LoveStoriesViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
var width = UIScreen.main.bounds.width
var height = UIScreen.main.bounds.height

class LoveStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //Variables
    let storyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: height - width/5, width: width, height: width/4), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        
        return collectionView
    }()
    
    var cells = [LoveStoryPostCell]()
    
    //Outlets
    
    //Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        
        storyCollectionView.register(LoveStoryPostCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(storyCollectionView)
        
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LoveStoryPostCell
        cells.append(cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/4, height: width/8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: width/40, bottom: 0, right: width/40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = cells[indexPath.row]
        UIView.animate(withDuration: 0.5) {
            cell.frame = CGRect(x: cell.frame.origin.x, y: width/40, width: cell.frame.width, height: cell.frame.height)
            cell.layer.transform = CATransform3DMakeScale(1.15, 1.15, 1)
        }
        
    }

}
