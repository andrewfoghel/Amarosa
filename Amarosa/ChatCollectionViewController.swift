//
//  ChatCollectionViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

private let reuseIdentifier = "cell"

class ChatCollectionViewController: UICollectionViewController,UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [Message]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = chosenUser.name
        
        
        observeMessages()
        setupKeyboardObservers()
        
        // Register cell classes
        self.collectionView?.keyboardDismissMode = .interactive
        self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //       self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView!.register(ChatMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //prevents memory leak of keyboard
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var inputContainer: ChatInputContainerView = {
        
        let chatInputContainer = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainer.chatLogController = self
        return chatInputContainer
    }()
    
    
    func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            print("heres the file url",videoUrl)
            
            let filename = NSUUID().uuidString
            let uploadTask = Storage.storage().reference().child("videos").child(filename).putFile(from: videoUrl, metadata: nil, completion: { (metadata, error) in
                if let err = error{
                    print("there was an error ",err.localizedDescription)
                }
                if let storageUrl = metadata?.downloadURL()?.absoluteString{
                    print(storageUrl)
                    
                    if let thumbnailImage = self.thumbNailImageForVideo(videoUrl: videoUrl){
                        self.uploadToFirebaseStorageUsingImage(selectedImage: thumbnailImage, completion: { (imageUrl) in
                            
                            let properties: [String:AnyObject] = ["videoUrl":storageUrl as AnyObject,"imageUrl":imageUrl as AnyObject,"imageWidth":thumbnailImage.size.width as AnyObject,"imageHeight":thumbnailImage.size.height as AnyObject]
                            self.sendMessageWithProperties(properties: properties)
                        })
                        
                    }
                    
                    
                }
            })
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                
                if let count = snapshot.progress?.completedUnitCount{
                    self.navigationItem.title = "\(Double(count/1000)) KB"
                }
                //  print(snapshot.progress?.completedUnitCount)
            })
            
            uploadTask.observe(.success, handler: { (snapshot) in
                self.navigationItem.title = chosenUser.name
            })
            
        }else{
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
                selectedImageFromPicker = editedImage
            }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker{
                uploadToFirebaseStorageUsingImage(selectedImage: selectedImage, completion: { (imageUrl) in
                    self.sendMessageWithImageUrl(imageUrl: imageUrl,image: selectedImage)
                })
                
            }
            
        }
        
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func thumbNailImageForVideo(videoUrl: URL) -> UIImage?{
        let asset = AVAsset(url: videoUrl)
        let assetGenterator = AVAssetImageGenerator(asset: asset)
        
        
        do{
            let thumbnailCGImage = try assetGenterator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        }catch let err{
            print(err.localizedDescription)
        }
        return nil
        
    }
    
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainer
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    func uploadToFirebaseStorageUsingImage(selectedImage: UIImage, completion:@escaping (_ imageUrl:String)->()){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if let err = error{
                    print("failed: ",err.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl)
                }
                
            })
        }
        
        
    }
    
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        let properties: [String:AnyObject] = ["imageUrl":imageUrl as AnyObject,"imageWidth":image.size.width as AnyObject,"imageHeight":image.size.height as AnyObject]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    func setupKeyboardObservers(){
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)*/
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func keyboardWillShow(notification: Notification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyBoardDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        containerViewBottomAnchor?.constant = -keyboardHeight
        //call this every time you want to animate constraints after you set the constraints
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyBoardDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    
    func handleSend(){
        let properties: [String:AnyObject] = ["text":inputContainer.inputTextField.text as AnyObject]
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String:AnyObject]){
        let reference = Database.database().reference().child("messages")
        let childRef = reference.childByAutoId()
        let toId = chosenUser.uid
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Date().timeIntervalSince1970
        var values:[String:AnyObject] = ["toId":toId,"fromId":fromId,"timeStamp":timeStamp] as [String : AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.inputContainer.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId!).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId:1])
        }
        
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        guard let otherUserId = chosenUser.uid else{
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child(otherUserId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
                
                
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height
        let message = messages[indexPath.item]
        if let text = messages[indexPath.item].text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageheight = message.imageHeight?.floatValue{
            
            
            //h1/w1 = h2/w2
            height =  CGFloat(imageheight / imageWidth * 200)
            
            
        }
        
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String)->CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }
    
    //fix constraints for landscape mode
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatMessageCell
        
        
        
        cell.chatLogController = self
        let message = messages[indexPath.row]
        
        cell.message = message
        
        
        setupCell(cell: cell, message: message)
        
        cell.textView.text = message.text
        
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        
        
         if let profileImageUrl = chosenUser.profileImageUrl{
         cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
         }
 
        if message.fromId == Auth.auth().currentUser?.uid{
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        }else{
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            cell.textView.textColor = .black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        }else{
            cell.messageImageView.isHidden = true
        }
        
        
    }
    
    
    var startingFrame: CGRect?
    var blackBackGround: UIView?
    var startingImageView: UIImageView?
    func performZoomInForstartingImageView(startingImageView: UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            
            blackBackGround = UIView(frame: keyWindow.frame)
            blackBackGround?.backgroundColor = .black
            blackBackGround?.alpha = 0
            keyWindow.addSubview(blackBackGround!)
            
            keyWindow.addSubview(zoomingImageView)
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                self.blackBackGround?.alpha = 1
                self.inputContainer.alpha = 0
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completed) in
                //
            })
            
            
        }
        
        
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackGround?.alpha = 0
                self.inputContainer.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
            
            
        }
    }
    
    
    
    
    
}
