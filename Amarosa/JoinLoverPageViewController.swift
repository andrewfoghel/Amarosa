//
//  JoinLoverPageViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit

class JoinLoverPageViewController: UIViewController, UISearchBarDelegate {

    var backBtn: UIButton?
    var joinLbl: UILabel?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI(){
        backBtn = UIButton(frame: CGRect(x: width/80, y: width/20, width: width/7.27, height: width/7.27))
        backBtn?.setImage(#imageLiteral(resourceName: "Back arrow"), for: .normal)
        backBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        view.addSubview(backBtn!)
        
        joinLbl = UILabel(frame: CGRect(x: 0, y: width/9, width: width, height: width/11))
        joinLbl?.text = "Create Loverpage"
        joinLbl?.font = UIFont(name: "Avenir Next", size: width/12.8)
        joinLbl?.textAlignment = .center
        joinLbl?.font = UIFont.boldSystemFont(ofSize: width/12.8)
        view.addSubview(joinLbl!)
        
       
        
    }
    
    func handleBack(gesture: UITapGestureRecognizer){
        performSegue(withIdentifier: "joinBack", sender: nil)
    }



}
