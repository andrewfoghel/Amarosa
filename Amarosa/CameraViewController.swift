//
//  CameraViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/11/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import SwiftyCam
import Firebase
import AVFoundation


class CameraViewController: AAPLCameraViewController, AAPLCameraVCDelegate{
    //Variables
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    var flashBtn: UIButton?
    var imageView: UIImageView?
    var exitBtn: UIButton?
    var postBtn: UIButton?
    var activityMonitor: UIActivityIndicatorView?
    var myUrl: URL?
    
    
    //Outlets
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var previewView: AAPLPreviewView!
    
    override func viewDidLoad() {
        
        delegate = self
        _previewView = previewView
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeCamera))
        gesture.numberOfTapsRequired = 2
        _previewView.addGestureRecognizer(gesture)
        
        
        recordBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePicture)))
        recordBtn.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleVideo)))
        
        super.viewDidLoad()
        
        flashBtn = UIButton(frame: CGRect(x: self.view.frame.midX - width/20.54, y: (height - width/4.92 - width/10.27 - 16), width: width/10.27, height: width/10.27))
        flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
//        flashBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFlash)))
        view.addSubview(flashBtn!)
        
    }
    
    func handlePicture(gesture: UITapGestureRecognizer){
        snapStillImage()
        
    }
    
    
    func handleVideo(gesture: UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            toggleMovieRecording()
            recordingHasStarted()
        case .ended:
            toggleMovieRecording()
        default:
            break
        }
    }
    
    @IBAction func changeCameraBtnPressed(_ sender: AnyObject) {
        changeCamera()
    }
    
    
    func shouldEnableCameraUI(_ enable: Bool) {
        cameraBtn.isEnabled = enable
        print("Should enable camera UI: \(enable)")
    }
    
    func shouldEnableRecordUI(_ enable: Bool) {
        recordBtn.isEnabled = enable
        print("Should enable record UI: \(enable)")
    }
    
    func recordingHasStarted() {
        print("Recording has started")
    }
    
    func canStartRecording() {
        print("Can start recording")
    }
    
    func videoRecordingFailed() {
        
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?

    func videoRecordingComplete(_ videoURL: URL!) {
        myUrl = videoURL
        player = AVPlayer(url: videoURL)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        view.layer.addSublayer(playerLayer!)
        player?.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
               self.player?.seek(to: kCMTimeZero)
               self.player?.play()
            }
        })
        
        exitBtn = UIButton(frame: CGRect(x: self.view.frame.midX - ((width/8.27) * 3), y: height - width/8.27 - 8, width: width/8.27, height: width/8.27))
        exitBtn?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        exitBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
        exitBtn?.layer.zPosition = 3
        postBtn = UIButton(frame: CGRect(x: self.view.frame.midX + ((width/8.27) * 2), y: height - width/8.27 - 8, width: width/8.27, height: width/8.27))
        postBtn?.setImage(#imageLiteral(resourceName: "post"), for: .normal)
        postBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostVideo)))
        postBtn?.layer.zPosition = 3
        view.addSubview(exitBtn!)
        view.addSubview(postBtn!)
        
        
    }
    
    
    func snapshotFailed() {
        
    }
    
    func snapshotTaken(_ snapshotData: Data!) {
        imageView = UIImageView(image: UIImage(data: snapshotData))
        imageView?.frame = self.view.frame
        exitBtn = UIButton(frame: CGRect(x: self.view.frame.midX - ((width/8.27) * 3), y: height - width/8.27 - 8, width: width/8.27, height: width/8.27))
        exitBtn?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        exitBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
        exitBtn?.layer.zPosition = 3
        postBtn = UIButton(frame: CGRect(x: self.view.frame.midX + ((width/8.27) * 2), y: height - width/8.27 - 8, width: width/8.27, height: width/8.27))
        postBtn?.setImage(#imageLiteral(resourceName: "post"), for: .normal)
        postBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostPhoto)))
        postBtn?.layer.zPosition = 3
        view.addSubview(exitBtn!)
        view.addSubview(imageView!)
        view.addSubview(postBtn!)
        
    }
    
    
    //Post Video to FireBase
    func handlePostVideo(gesture: UITapGestureRecognizer){
        view.isUserInteractionEnabled = false
        activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityMonitor?.frame = CGRect(x: self.view.frame.midX - width/8.53, y: self.view.frame.midY - width/8.53, width: width/4.26, height: width/4.26)
        activityMonitor?.hidesWhenStopped = true
        activityMonitor?.layer.zPosition = 3
        activityMonitor?.startAnimating()
        view.addSubview(activityMonitor!)
        
        var uuid = UUID().uuidString
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let videoName = "\(uuid)\(myUrl)"
        
        Storage.storage().reference().child("love-story-videos").child(videoName).putFile(from: myUrl!, metadata: nil) { (metadata, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            
            if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                Database.database().reference().child("loveStories").child(uid).childByAutoId().setValue(["storyVideoUrl":downloadUrl,"poster":uid], withCompletionBlock: { (error, ref) in
                    if let err = error{
                        print(err.localizedDescription)
                        return
                    }
                    
                    self.activityMonitor?.stopAnimating()
                    self.exitBtn?.removeFromSuperview()
                    self.postBtn?.removeFromSuperview()
                    self.playerLayer?.removeFromSuperlayer()
                    self.view.isUserInteractionEnabled = true
                    
                    print("Success Video Post")
                })
            }
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    //Post Photo to FireBase
    func handlePostPhoto(gesture: UITapGestureRecognizer){
        
        view.isUserInteractionEnabled = false
        activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityMonitor?.frame = CGRect(x: self.view.frame.midX - width/8.53, y: self.view.frame.midY - width/8.53, width: width/4.26, height: width/4.26)
        activityMonitor?.hidesWhenStopped = true
        activityMonitor?.layer.zPosition = 3
        activityMonitor?.startAnimating()
        view.addSubview(activityMonitor!)
        
        let uuid = UUID().uuidString
        
      
        
        if let image = imageView?.image{
            if let data = UIImageJPEGRepresentation(image, 0.5){
                Storage.storage().reference().child("love-story-photos").child(uuid).putData(data, metadata: nil, completion: { (metadata, error ) in
                    if let err = error{
                        print(err.localizedDescription)
                        return
                    }
                    
                    guard let uid = Auth.auth().currentUser?.uid else{
                        return
                    }
                    
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                       
                        Database.database().reference().child("loveStories").child(uid).childByAutoId().setValue(["storyImageUrl":downloadURL,"imageWidth":image.size.width,"imageHeight": image.size.height,"poster":uid], withCompletionBlock: {(error, ref) in
                            if let err = error{
                                print(err.localizedDescription)
                                return
                            }
                           
                        })
                    }
                    self.activityMonitor?.stopAnimating()
                    self.exitBtn?.removeFromSuperview()
                    self.postBtn?.removeFromSuperview()
                    self.imageView?.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                })
            }
        }
    }
    

    
    
    
    
    
    
    
    func dismissOnTap(gesture: UITapGestureRecognizer){
        exitBtn?.removeFromSuperview()
        imageView?.removeFromSuperview()
        playerLayer?.removeFromSuperlayer()
        postBtn?.removeFromSuperview()
    }
    
    
}

    
    /*
    
    //set flash
    func handleFlash(gesture: UITapGestureRecognizer){
        flashEnabled = !flashEnabled
        
        if flashEnabled == true{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash TRUE"), for: .normal)
        }else{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
        }
    }
 
*/
    
