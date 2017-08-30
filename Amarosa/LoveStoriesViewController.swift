//
//  LoveStoriesViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/14/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase
var width = UIScreen.main.bounds.width
var height = UIScreen.main.bounds.height
var isDrawable = false

class LoveStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

    //Variables

    var lovePagesToDisplay = [LoverStoryPage]()
    var comments = [Comment]()
    var commentImages = [String]()
        
    let storyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: height - width/5, width: width, height: width/4), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.zPosition = 10
        collectionView.layer.masksToBounds = true
        
        return collectionView
    }()
    
    let commentorTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: width - width/10.67 - width/40, y: width/10, width: width/10.67, height: height - width/4 - width/6))
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    var images = Set<String>()
    var imageView: UIImageView?
    var myView: UIView?
    var commentImageView: UIImageView?
    var commentBtn: UIButton?
    var cheerBtn: UIButton?
    var gifView: UIImageView?
    
    var viewCommentImageView: UIImageView?
    
    var topImage: UIImageView?
    var topLbl: UILabel?
    var posterImage: UIImageView?
    var numberLbl: UILabel?
    
    var red: CGFloat = 1
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    var lastPoint = CGPoint.zero
    var swiped = false
    
    
    var cancelBtn: UIButton?
    var postBtn: UIButton?
    var textBtn: UIButton?
    var redBtn: UIButton?
    var redFrame: CGRect?
    var orangeBtn: UIButton?
    var orangeFrame: CGRect?
    var yellowBtn: UIButton?
    var yellowFrame: CGRect?
    var greenBtn: UIButton?
    var greenFrame: CGRect?
    var blueBtn: UIButton?
    var blueFrame: CGRect?
    var purpleBtn: UIButton?
    var purpleFrame: CGRect?
    var pinkBtn: UIButton?
    var pinkFrame: CGRect?
    var whiteBtn: UIButton?
    var whiteFrame: CGRect?
    var blackBtn: UIButton?
    var blackFrame: CGRect?
    var undoBtn: UIButton?
    var drawBtn: UIButton?
    var saveBtn: UIButton?
    var colorLbl: UILabel?
    var backImages = [UIImage]()
    var backImage = UIImage()
    var textEditField: UITextField?
    var inTextEdit = false
    
    var cells = [LoveStoryPostCell]()
    
    //Outlets
    
    //Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        storyCollectionView.register(LoveStoryPostCell.self, forCellWithReuseIdentifier: "cell")

        observeCelebratingLovePages()
        setupUI()
        
        commentorTableView.reloadData()
        
    }
    
    func observeCelebratingLovePages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        Database.database().reference().child("celebrators").child(uid).observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    Database.database().reference().child("loverProfiles").child(snap.key).observe(.value, with: { (secondSnapshot) in
                        if let dictionary = secondSnapshot.value as? [String:AnyObject]{
                            let thisLovePage = LoverStoryPage()
                            thisLovePage.username = dictionary["username"] as? String
                            thisLovePage.loverPageImageUrl = dictionary["lovePageurl"] as? String
                            thisLovePage.lovers = dictionary["lovers"] as? [String]
                            thisLovePage.posts = dictionary["post"] as? [String:AnyObject]
                           
                            if (dictionary["post"] as? [String:AnyObject]) == nil{
                                return
                            }else{
                                self.lovePagesToDisplay.append(thisLovePage)
                            }
                            self.observePosts()
                        }
                    })
                }
            }
        })

    }
    
    func setupUI(){
        
        topImage = UIImageView(frame: CGRect(x: width/40, y: width/10, width: width/3.5, height: width/5.75))
        topImage?.layer.borderColor = UIColor.red.cgColor
        topImage?.layer.borderWidth = width/160
        topImage?.layer.cornerRadius = width/64
        topImage?.contentMode = .scaleAspectFill
        topImage?.layer.zPosition = 4
        topImage?.layer.masksToBounds = true
        view.addSubview(topImage!)
        
        viewCommentImageView = UIImageView(frame: self.view.frame)
        viewCommentImageView?.layer.zPosition = 20
        viewCommentImageView?.isUserInteractionEnabled = true
        viewCommentImageView?.layer.masksToBounds = true
        
        topLbl = UILabel(frame: CGRect(x: width/40 + width/3.5 + width/64, y: (topImage?.frame.origin.y)!, width: width, height: width/16))
        topLbl?.textColor = UIColor.white
        topLbl?.font = UIFont(name: "Avenir Next", size: width/22)
        topLbl?.font = UIFont.boldSystemFont(ofSize: width/22)
        topLbl?.layer.zPosition = 4
        topLbl?.layer.masksToBounds = true
        view.addSubview(topLbl!)
        
        posterImage = UIImageView(frame: CGRect(x: width/40 + width/3.5 + width/160, y: (topImage?.frame.origin.y)! + width/16 + width/160, width: width/12.8, height: width/12.8))
        posterImage?.layer.zPosition = 3
        posterImage?.layer.cornerRadius = (posterImage?.frame.height)!/2
        posterImage?.contentMode = .scaleAspectFill
        posterImage?.layer.masksToBounds = true
        view.addSubview(posterImage!)
        
       // numberLbl = UILabel(frame: CGRect(x: width/40 + width/3.5 + width/160, y: (topImage?.frame.origin.y)! + width/16 + width/12.8, width: width/32, height: width/32))
        numberLbl = UILabel(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 50, height: 50))
        numberLbl?.textColor = UIColor.white
        numberLbl?.layer.zPosition = 3
        numberLbl?.layer.masksToBounds = true
        view.addSubview(numberLbl!)
        
        commentorTableView.delegate = self
        commentorTableView.dataSource = self
        commentorTableView.register(CommentCell.self, forCellReuseIdentifier: "tablecell")
        commentorTableView.separatorStyle = .none
        commentorTableView.backgroundColor = .clear
        commentorTableView.layer.zPosition = 3
        commentorTableView.layer.masksToBounds = true
        view.addSubview(commentorTableView)
        
        view.addSubview(storyCollectionView)
        
        imageView = UIImageView(frame: self.view.frame)
        imageView?.contentMode = .scaleAspectFill
        view.addSubview(imageView!)
        
        commentImageView = UIImageView(frame: self.view.frame)
        commentImageView?.contentMode = .scaleAspectFill
        view.addSubview(commentImageView!)
        
        commentBtn = UIButton(frame: CGRect(x: width - width/10.67 - width/40, y: commentorTableView.frame.origin.y + commentorTableView.frame.size.height, width: width/10.67, height: width/10.67))
        commentBtn?.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        commentBtn?.layer.zPosition = 11
        commentBtn?.layer.masksToBounds = true
        commentBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleComment)))
        view.addSubview(commentBtn!)
        
        gifView = UIImageView(frame: view.frame)
        gifView?.contentMode = .scaleAspectFill
        gifView?.layer.zPosition = 10
        gifView?.layer.masksToBounds = true
        
        cheerBtn = UIButton(frame: CGRect(x: width - width/10.67 - width/40, y: (commentBtn?.frame.origin.y)! + width/10.67, width: width/10.67, height: width/10.67))
        cheerBtn?.setImage(#imageLiteral(resourceName: "confetti"), for: .normal)
        cheerBtn?.layer.zPosition = 11
        cheerBtn?.layer.masksToBounds = true
        cheerBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGif)))
        view.addSubview(cheerBtn!)
        
        myView = UIView(frame: CGRect(x: 0, y: 40, width: width - width/5.335 - width/40, height: height - storyCollectionView.frame.height - 40))
        myView?.layer.zPosition = 10
        myView?.layer.masksToBounds = true
        view.addSubview(myView!)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEdit)))
        
        blackBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: view.frame.midY + width/8, width: width/25, height: width/25)) //at scale width/21.33
        blackBtn?.backgroundColor = UIColor.black
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        blackBtn?.layer.borderColor = UIColor.white.cgColor
        blackBtn?.layer.borderWidth = width/160
        blackBtn?.layer.zPosition = 11
        blackBtn?.layer.masksToBounds = true
        blackBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blackColor)))
        view.addSubview(blackBtn!)
        
        whiteBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (blackBtn?.frame.origin.y)! + (blackBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        whiteBtn?.backgroundColor = UIColor.white
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        whiteBtn?.layer.borderColor = UIColor.white.cgColor
        whiteBtn?.layer.borderWidth = width/160
        whiteBtn?.layer.masksToBounds = true
        whiteBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(whiteColor)))
        view.addSubview(whiteBtn!)
        
        pinkBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (whiteBtn?.frame.origin.y)! + (whiteBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        pinkBtn?.backgroundColor = UIColor(red: 1, green: 0.28, blue: 0.80, alpha: 1)
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        pinkBtn?.layer.borderColor = UIColor.white.cgColor
        pinkBtn?.layer.borderWidth = width/160
        pinkBtn?.layer.masksToBounds = true
        pinkBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pinkColor)))
        view.addSubview(pinkBtn!)
        
        purpleBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (pinkBtn?.frame.origin.y)! + (pinkBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        purpleBtn?.backgroundColor = UIColor(red: 0.7, green: 0.26, blue: 1, alpha: 1)
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        purpleBtn?.layer.borderColor = UIColor.white.cgColor
        purpleBtn?.layer.borderWidth = width/160
        purpleBtn?.layer.masksToBounds = true
        purpleBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(purpleColor)))
        view.addSubview(purpleBtn!)
        
        blueBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (purpleBtn?.frame.origin.y)! + (purpleBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        blueBtn?.backgroundColor = UIColor(red: 0.1, green: 0.77, blue: 0.97, alpha: 1)
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        blueBtn?.layer.borderColor = UIColor.white.cgColor
        blueBtn?.layer.borderWidth = width/160
        blueBtn?.layer.masksToBounds = true
        blueBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blueColor)))
        view.addSubview(blueBtn!)
        
        greenBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (blueBtn?.frame.origin.y)! + (blueBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        greenBtn?.backgroundColor = UIColor(red: 0.1, green: 0.97, blue: 0.25, alpha: 1)
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        greenBtn?.layer.borderColor = UIColor.white.cgColor
        greenBtn?.layer.borderWidth = width/160
        greenBtn?.layer.masksToBounds = true
        greenBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(greenColor)))
        view.addSubview(greenBtn!)
        
        yellowBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (greenBtn?.frame.origin.y)! + (greenBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        yellowBtn?.backgroundColor = UIColor(red: 0.96, green: 0.9, blue: 0.1, alpha: 1)
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        yellowBtn?.layer.borderColor = UIColor.white.cgColor
        yellowBtn?.layer.borderWidth = width/160
        yellowBtn?.layer.masksToBounds = true
        yellowBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(yellowColor)))
        view.addSubview(yellowBtn!)
        
        orangeBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: (yellowBtn?.frame.origin.y)! + (yellowBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)) //at scale width/21.33
        orangeBtn?.backgroundColor = UIColor(red: 1, green: 0.71, blue: 0.007, alpha: 1)
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        orangeBtn?.layer.borderColor = UIColor.white.cgColor
        orangeBtn?.layer.borderWidth = width/160
        orangeBtn?.layer.masksToBounds = true
        orangeBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(orangeColor)))
        view.addSubview(orangeBtn!)
        
        redBtn = UIButton(frame: CGRect(x: width - width/40 - width/15, y: (orangeBtn?.frame.origin.y)! + (orangeBtn?.frame.size.height)! + width/40, width: width/20, height: width/20)) //at scale width/21.33
        redBtn?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
        redBtn?.layer.borderColor = UIColor.white.cgColor
        redBtn?.layer.borderWidth = width/160
        redBtn?.layer.masksToBounds = true
        redBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redColor)))
        view.addSubview(redBtn!)
        
        blackFrame = blackBtn?.frame
        whiteFrame = whiteBtn?.frame
        blueFrame = blueBtn?.frame
        purpleFrame = purpleBtn?.frame
        yellowFrame = yellowBtn?.frame
        greenFrame = greenBtn?.frame
        orangeFrame = orangeBtn?.frame
        pinkFrame = pinkBtn?.frame
        redFrame = CGRect(x: width - width/40 - width/16, y: (orangeBtn?.frame.origin.y)! + (orangeBtn?.frame.size.height)! + width/40, width: width/25, height: width/25)
        
        cancelBtn = UIButton(frame: CGRect(x: width/40,y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
        cancelBtn?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        cancelBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCancel)))
        view.addSubview(cancelBtn!)
        
        postBtn = UIButton(frame: CGRect(x: width - width/8.27 - width/40, y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
        postBtn?.setImage(#imageLiteral(resourceName: "post"), for: .normal)
        postBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePost)))
        view.addSubview(postBtn!)
        
        textBtn = UIButton(frame: CGRect(x: self.view.frame.midX - width/16 - width/6, y: height - width/16 - width/16, width: width/8, height: width/12.5))
        textBtn?.setTitle("Aa", for: .normal)
        textBtn?.titleLabel?.font = UIFont.boldSystemFont(ofSize: width/12.8)
        textBtn?.titleLabel?.font = UIFont(name: "Avenir Next", size: width/12.8)
        textBtn?.setTitleColor(.black, for: .normal)
      textBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleText)))
        view.addSubview(textBtn!)
        
        drawBtn = UIButton(frame: CGRect(x: self.view.frame.midX + width/25 + width/8, y: height - width/16 - width/16, width: width/12.5, height: width/12.5))
        drawBtn?.setImage(#imageLiteral(resourceName: "drawButton"), for: .normal)
        drawBtn?.tintColor = UIColor.black
        drawBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDraw)))
        view.addSubview(drawBtn!)
        
        saveBtn = UIButton(frame: CGRect(x: (cancelBtn?.center.x)! - width/21.33, y: (cancelBtn?.frame.origin.y)! - width/10.66 - width/40, width: width/10.66, height: width/10.66))
        saveBtn?.setImage(#imageLiteral(resourceName: "Save"), for: .normal)
        saveBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSave)))
        view.addSubview(saveBtn!)
        
        undoBtn = UIButton(frame: CGRect(x: width - width/40 - width/16, y: view.frame.midY, width: width/25, height: width/25))
        undoBtn?.setImage(#imageLiteral(resourceName: "Undo"), for: .normal)
        undoBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUndo)))
        view.addSubview(undoBtn!)
        
        undoBtn?.isHidden = true
        redBtn?.isHidden = true
        orangeBtn?.isHidden = true
        yellowBtn?.isHidden = true
        greenBtn?.isHidden = true
        blueBtn?.isHidden = true
        purpleBtn?.isHidden = true
        pinkBtn?.isHidden = true
        whiteBtn?.isHidden = true
        blackBtn?.isHidden = true
        textBtn?.isHidden = true
        drawBtn?.isHidden = true
        saveBtn?.isHidden = true
        cancelBtn?.isHidden = true
        postBtn?.isHidden = true
        commentImageView?.isHidden = true
    }
  
    func handleUndo(gesture: UITapGestureRecognizer){
        if backImages.count == 0{
            //imageView?.image = #imageLiteral(resourceName: "Andrew") //this would be the loverStory image hence original image
        }else{
            backImage = backImages.popLast()!
            commentImageView?.image = backImage
        }
    }
    
    func handleCancel(gesture: UITapGestureRecognizer){
        isDrawable = false
        commentImageView?.isHidden = true
        imageView?.isHidden = false
        redBtn?.isHidden = true
        orangeBtn?.isHidden = true
        yellowBtn?.isHidden = true
        greenBtn?.isHidden = true
        blueBtn?.isHidden = true
        purpleBtn?.isHidden = true
        pinkBtn?.isHidden = true
        whiteBtn?.isHidden = true
        blackBtn?.isHidden = true
        textBtn?.isHidden = true
        drawBtn?.isHidden = true
        saveBtn?.isHidden = true
        cancelBtn?.isHidden = true
        postBtn?.isHidden = true
        storyCollectionView.isHidden = false
        commentBtn?.isHidden = false
        myView?.isHidden = false
        undoBtn?.isHidden = true
        textEditField?.removeFromSuperview()
        topLbl?.isHidden = false
        topImage?.isHidden = false
        posterImage?.isHidden = false
        numberLbl?.isHidden = false
        commentorTableView.isHidden = false
        cheerBtn?.isHidden = false

    }
   
    func endEdit(gesture: UITapGestureRecognizer){
        inTextEdit = false
        self.view.endEditing(true)

    }
    
    func handleGif(gesture: UITapGestureRecognizer){
        gifView?.loadGif(name: "gif")
        view.addSubview(gifView!)
        cheerBtn?.setImage(#imageLiteral(resourceName: "confettiTrue"), for: .normal)
        delay(1) {
            self.gifView?.removeFromSuperview()
        }
        
    }
    
    func handlePost(gesture: UITapGestureRecognizer){
        if let image = commentImageView?.image{
            if let uploadData = UIImageJPEGRepresentation(image, 0.5){
                let uuid = UUID().uuidString
                Storage.storage().reference().child("love-story-comments").child(uuid).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let err = error{
                        print(err.localizedDescription)
                        return
                    }
                    
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                     //NEED CURRENT POST ID COMMENTS WILL BE ADDED IN LOVESTORIES
                        Database.database().reference().child("comments").child(self.postId!).child((Auth.auth().currentUser?.uid)!).updateChildValues([uuid:downloadUrl], withCompletionBlock: { (error, reference) in
                            if let err = error{
                                print(err.localizedDescription)
                                return
                            }
                            print("Great Success")
                        })
                    }
                    
                })
            }
        }
    }
    
    func handleDraw(gesture: UITapGestureRecognizer){
        isDrawable = !isDrawable
    }
    
    func handleSave(gesture: UITapGestureRecognizer){
        if let image = commentImageView?.image{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lovePagesToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LoveStoryPostCell
        cells.append(cell)
        
        let thisPage = lovePagesToDisplay[indexPath.row]
        cell.imageView.loadImageUsingCacheWithUrlString(urlString: thisPage.loverPageImageUrl!)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/4, height: width/8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: width/40, bottom: 0, right: width/40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var viewingLovePage = lovePagesToDisplay[indexPath.row]
        lovePagesToDisplay.remove(at: indexPath.row)
        lovePagesToDisplay.insert(viewingLovePage, at: 0)
        self.attemptReloadOfTable()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return width/7.5
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! CommentCell
        cell.backgroundColor = .clear
        let comment = comments[indexPath.row]
        Database.database().reference().child("users").child(comment.userId!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                cell.myImageView.loadImageUsingCacheWithUrlString(urlString: (dictionary["profileImageUrl"] as? String)!)
            }
        })
        cell.myImageView.layer.cornerRadius = width/21.34
        cell.myImageView.layer.masksToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    
    var comment = Comment()
    var index: Int?
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        comment = comments[indexPath.row]
        index = indexPath.row
        viewCommentImageView?.loadImageUsingCacheWithUrlString(urlString: comment.commentUrls?.first?.value as! String)
        viewCommentImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNextComment)))
        view.addSubview(viewCommentImageView!)
    }
    
    func handleNextComment(gesture: UITapGestureRecognizer){
        if (comment.commentUrls?.count)! > 1{
            let firstKey = comment.commentUrls?.first?.key
            comment.commentUrls?.removeValue(forKey: firstKey!)
            viewCommentImageView?.loadImageUsingCacheWithUrlString(urlString: comment.commentUrls?.first?.value as! String)
        }else{
            comment.commentUrls?.removeAll()
            viewCommentImageView?.image = nil
            viewCommentImageView?.removeFromSuperview()
            comments.remove(at: index!)
            commentorTableView.reloadData()
        }
    }
    
    

    var postPosterUrl: String?
    var postId: String?
    func observePosts(){
        if lovePagesToDisplay.count >= 1{
            var lovePage = lovePagesToDisplay[0]
            topImage?.loadImageUsingCacheWithUrlString(urlString: lovePage.loverPageImageUrl!)
            topLbl?.text = lovePage.username
            for post in lovePage.posts!{
                print(post.key)
                self.postId = post.key
                Database.database().reference().child("loveStories").child(post.key).observeSingleEvent(of: .value, with: { (mySnapshot) in
                    if let dictionary = mySnapshot.value as? [String:AnyObject]{
                        let post = Post()
                        post.poster = dictionary["poster"] as? String
                        let imageUrl = dictionary["storyImageUrl"] as? String
                        self.images.insert(imageUrl!)
                        self.imageView?.loadImageUsingCacheWithUrlString(urlString: self.images.first!)
                        self.myView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextImage)))
                        
                        Database.database().reference().child("users").child(post.poster!).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let dictionary = snapshot.value as? [String:AnyObject]{
                                self.postPosterUrl = dictionary["profileImageUrl"] as! String
                                self.posterImage?.loadImageUsingCacheWithUrlString(urlString: self.postPosterUrl!)
                            }
                        })

                        
                    }
                    self.numberLbl?.text = "\(self.images.count)"
                    self.attemptReloadOfTable()
                })
                Database.database().reference().child("comments").child(post.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    self.comments.removeAll()
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshot{
                            let comment = Comment()
                            comment.userId = snap.key
                            comment.commentUrls = snap.value as? [String:AnyObject]
                            self.comments.append(comment)
                            print(self.comments.count)
                        }
                    }
                    self.commentorTableView.reloadData()
                })
            
            }
        }else{
            self.attemptReloadOfTable()
        }
    }
    func nextImage(gesture: UITapGestureRecognizer){
        if images.count > 1{
        self.images.removeFirst()
        self.numberLbl?.text = "\(images.count)"
            imageView?.loadImageUsingCacheWithUrlString(urlString: images.first!)
        }else if lovePagesToDisplay.count > 0{
        self.images.removeAll()
        lovePagesToDisplay.remove(at: 0)
        observePosts()
        }else{
        return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if commentImageView?.image != nil{
            backImages.append((commentImageView?.image)!)
            if isDrawable == true{
            swiped = false
        
            if let touch = touches.first{
                lastPoint = touch.location(in: self.view)
            }
            }else{
                return
            }
        }
    }
    
    func drawLines(fromPoint:CGPoint, toPoint: CGPoint){
        UIGraphicsBeginImageContext(self.view.frame.size)
        commentImageView?.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        //Set up line
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor)
        //start stroke
        context?.strokePath()
        
        commentImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawable == true{
        swiped = true
            
        if let touch = touches.first{
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
            
            }
        }else{
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if isDrawable{
        if !swiped{
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
            }
        }else{
            return
        }
    }
    
    func handleComment(gesture: UITapGestureRecognizer){
        commentBtn?.isHidden = true
        imageView?.isHidden = true
        myView?.isHidden = true
        commentImageView?.isHidden = false
        redBtn?.isHidden = false
        orangeBtn?.isHidden = false
        yellowBtn?.isHidden = false
        greenBtn?.isHidden = false
        blueBtn?.isHidden = false
        purpleBtn?.isHidden = false
        pinkBtn?.isHidden = false
        whiteBtn?.isHidden = false
        blackBtn?.isHidden = false
        textBtn?.isHidden = false
        drawBtn?.isHidden = false
        saveBtn?.isHidden = false
        cancelBtn?.isHidden = false
        postBtn?.isHidden = false
        storyCollectionView.isHidden = true
        commentImageView?.image = imageView?.image
        undoBtn?.isHidden = false
        topLbl?.isHidden = true
        topImage?.isHidden = true
        posterImage?.isHidden = true
        numberLbl?.isHidden = true
        commentorTableView.isHidden = true
        cheerBtn?.isHidden = true

    }
    
    //COLOR FUNCTIONS
    func blackColor(gesture: UITapGestureRecognizer){
        blackBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: view.frame.midY + width/8, width: width/20, height: width/20)
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        blackBtn?.layer.masksToBounds = true
        (red,green,blue) = (0,0,0)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2

        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2

        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2

        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2

        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2

        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2

        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2

    }
    
    func whiteColor(gesture: UITapGestureRecognizer){
        whiteBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (whiteFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        whiteBtn?.layer.masksToBounds = true
        (red,green,blue) = (1,1,1)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
    }
    
    func pinkColor(gesture: UITapGestureRecognizer){
        pinkBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (pinkFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        pinkBtn?.layer.masksToBounds = true
        (red,green,blue) = (1,0.28,0.8)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
        
    }
    
    func purpleColor(gesture: UITapGestureRecognizer){
        purpleBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (purpleFrame?.origin.y)! - width/160, width: width/20 , height: width/20)
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        purpleBtn?.layer.masksToBounds = true
        (red,green,blue) = (0.7,0.26,1)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
        
    }
    
    func blueColor(gesture: UITapGestureRecognizer){
        blueBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (blueFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        blueBtn?.layer.masksToBounds = true
        (red,green,blue) = (0.1,0.77,0.97)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
    }
    
    func greenColor(gesture: UITapGestureRecognizer){
        greenBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (greenFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        greenBtn?.layer.masksToBounds = true
        (red,green,blue) = (0.1,0.97,0.25)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
    }
    
    func yellowColor(gesture: UITapGestureRecognizer){
        yellowBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (yellowFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        yellowBtn?.layer.masksToBounds = true
        (red,green,blue) = (0.96,0.9,0.1)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
    }
    
    func orangeColor(gesture: UITapGestureRecognizer){
        orangeBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (orangeFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        orangeBtn?.layer.masksToBounds = true
        (red,green,blue) = (1,0.71,0.007)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
        
        redBtn?.frame = redFrame!
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
    }
    
    func redColor(gesture: UITapGestureRecognizer){
        redBtn?.frame = CGRect(x: width - width/40 - width/14.75, y: (redFrame?.origin.y)! - width/160, width: width/20, height: width/20)
        redBtn?.layer.cornerRadius = (redBtn?.frame.size.width)!/2
        redBtn?.layer.masksToBounds = true
        (red,green,blue) = (1,0,0)
        
        textEditField?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        blackBtn?.frame = blackFrame!
        blackBtn?.layer.cornerRadius = (blackBtn?.frame.size.width)!/2
        
        pinkBtn?.frame = pinkFrame!
        pinkBtn?.layer.cornerRadius = (pinkBtn?.frame.size.width)!/2
        
        purpleBtn?.frame = purpleFrame!
        purpleBtn?.layer.cornerRadius = (purpleBtn?.frame.size.width)!/2
        
        blueBtn?.frame = blueFrame!
        blueBtn?.layer.cornerRadius = (blueBtn?.frame.size.width)!/2
        
        greenBtn?.frame = greenFrame!
        greenBtn?.layer.cornerRadius = (greenBtn?.frame.size.width)!/2
        
        yellowBtn?.frame = yellowFrame!
        yellowBtn?.layer.cornerRadius = (yellowBtn?.frame.size.width)!/2
        
        orangeBtn?.frame = orangeFrame!
        orangeBtn?.layer.cornerRadius = (orangeBtn?.frame.size.width)!/2
        
        whiteBtn?.frame = whiteFrame!
        whiteBtn?.layer.cornerRadius = (whiteBtn?.frame.size.width)!/2
    }
    
    func handleText(gesture: UITapGestureRecognizer){
       
        inTextEdit = true
        
        textEditField = UITextField(frame: CGRect(x: 0, y: view.frame.midY, width: width, height: width/10.67))
        textEditField?.textColor = .white
        textEditField?.textAlignment = .center
        textEditField?.becomeFirstResponder()
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handleTextResize)))
        textEditField?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDrag)))
        textEditField?.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(handleRotate)))
        view.addSubview(textEditField!)
        // this save doesn't handle rotate or resize and needs to be done dynamically somewhere
        let image = imageView?.image?.addText((textEditField?.text)!, atPoint: (textEditField?.frame.origin)!, textColor: textEditField?.textColor, textFont: UIFont(name: "Avenir Next", size: (textEditField?.frame.size.height)! - width/64))
        imageView?.image = image
        
    }

    func handleRotate(gesture: UIRotationGestureRecognizer){
        var lastRotation: CGFloat = 0
        var originalRotation = CGFloat()

        if gesture.state == .began {
            gesture.rotation = lastRotation
            originalRotation = gesture.rotation
        } else if gesture.state == .changed {
            let newRotation = gesture.rotation + originalRotation
            gesture.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        } else if gesture.state == .ended {
            lastRotation = gesture.rotation
        }
        
    }
    
    func handleDrag(gesture: UIPanGestureRecognizer){
        let loc = gesture.location(in: self.view)
        self.textEditField?.center = loc
    }
    
    func handleTextResize(gesture: UIPinchGestureRecognizer){
        var pinchScale = gesture.scale
        pinchScale = round(pinchScale * 1000) / 1000.0
        
        if (pinchScale < 1) {
            textEditField?.font = UIFont( name: "Avenir Next", size: (textEditField?.font?.pointSize)! - pinchScale)
            textEditField?.frame.size.height = (textEditField?.font?.pointSize)! - pinchScale + width/64
        }
        else{
            textEditField?.font = UIFont( name: "Avenir Next", size: (textEditField?.font?.pointSize)! + pinchScale)
            textEditField?.frame.size.height = (textEditField?.font?.pointSize)! + pinchScale + width/64

        }
    }
    
    var timer: Timer?
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        storyCollectionView.reloadData()
    }
    
    }

extension UIImage {
    
    
    
    func addText(_ drawText: String, atPoint: CGPoint, textColor: UIColor?, textFont: UIFont?) -> UIImage {
        
        // Setup the font specific variables
        var _textColor: UIColor
        if textColor == nil {
            _textColor = UIColor.white
        } else {
            _textColor = textColor!
        }
        
        var _textFont: UIFont
        if textFont == nil {
            _textFont = UIFont.systemFont(ofSize: 16)
        } else {
            _textFont = textFont!
        }
        
        // Setup the image context using the passed image
        UIGraphicsBeginImageContext(size)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: _textFont,
            NSForegroundColorAttributeName: _textColor,
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: size.width, height: size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
}

class CommentCell: UITableViewCell{
    var myImageView: UIImageView = {
       let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        myImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        myImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        myImageView.widthAnchor.constraint(equalToConstant: width/10.67).isActive = true
        myImageView.heightAnchor.constraint(equalToConstant: width/10.67).isActive = true
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(myImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


