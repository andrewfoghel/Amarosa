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
    var flashEnabled = false
    var front = false
    var flashView: UIView?
    
    var loverStoryId: String?
    
    //Outlets
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var previewView: AAPLPreviewView!
    
    override func viewDidLoad() {
        
        delegate = self
        _previewView = previewView
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleChangeCamera))
        gesture.numberOfTapsRequired = 2
        _previewView.addGestureRecognizer(gesture)
        _previewView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch)))
        
        recordBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePicture)))
        recordBtn.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleVideo)))
        
        super.viewDidLoad()
        
        getLoverStoryId()
        
        flashView = UIView(frame: self.view.frame)
        flashView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
        
        flashBtn = UIButton(frame: CGRect(x: self.view.frame.midX - width/20.54, y: (height - width/4.92 - width/10.27 - 16), width: width/10.27, height: width/10.27))
        flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
        flashBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFlash)))
        view.addSubview(flashBtn!)
        
    }
    
    func getLoverStoryId(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                self.loverStoryId = dictionary["lovePage"] as? String
            }
        })
        
    }
    
    func handlePicture(gesture: UITapGestureRecognizer){
        if flashEnabled == true{
        toggleFlash()
            delay(0.5, completion: {
                self.snapStillImage()
                self.toggleFlash()
                self.flashView?.removeFromSuperview()
            })
        }else{
            snapStillImage()
        }
    }
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    func pinch(_ pinch: UIPinchGestureRecognizer) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device!.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device?.lockForConfiguration()
                defer { device?.unlockForConfiguration() }
                device?.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    func handleVideo(gesture: UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            if flashEnabled == true{
                toggleFlash()
                toggleMovieRecording()
                recordingHasStarted()
            }else{
                toggleMovieRecording()
                recordingHasStarted()
            }
        case .ended:
            if flashEnabled == true{
                toggleFlash()
                flashView?.removeFromSuperview()
            }
                toggleMovieRecording()
        default:
            break
        }
    }
    
    @IBAction func changeCameraBtnPressed(_ sender: AnyObject) {
        changeCamera()
    }
    
    func handleChangeCamera(gesture: UITapGestureRecognizer){
        front = !front
        changeCamera()
        if front == true{
            print("front")
        }else{
            print("back")
        }
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
        
        exitBtn = UIButton(frame: CGRect(x: self.view.frame.midX - ((width/8.27) * 3), y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
        exitBtn?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        exitBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
        exitBtn?.layer.zPosition = 3
        postBtn = UIButton(frame: CGRect(x: self.view.frame.midX + ((width/8.27) * 2), y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
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
        exitBtn = UIButton(frame: CGRect(x: self.view.frame.midX - ((width/8.27) * 3), y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
        exitBtn?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        exitBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
        exitBtn?.layer.zPosition = 3
        postBtn = UIButton(frame: CGRect(x: self.view.frame.midX + ((width/8.27) * 2), y: height - width/8.27 - width/40, width: width/8.27, height: width/8.27))
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
            let myUuid = UUID().uuidString
            if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                Database.database().reference().child("loveStories").child(myUuid).setValue(["storyVideoUrl":downloadUrl,"poster":uid], withCompletionBlock: { (error, ref) in
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
                    
                    Database.database().reference().child("loverProfiles").child(self.loverStoryId!).child("post").updateChildValues([myUuid:1], withCompletionBlock: { (error, ref) in
                        if let err = error{
                            print(err.localizedDescription)
                            return
                        }
                        print("good job")
                    })
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
                    let myUuid = UUID().uuidString
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                       
                        Database.database().reference().child("loveStories").child(myUuid).setValue(["storyImageUrl":downloadURL,"imageWidth":image.size.width,"imageHeight": image.size.height,"poster":uid], withCompletionBlock: {(error, ref) in
                            if let err = error{
                                print(err.localizedDescription)
                                return
                            }
                            Database.database().reference().child("loverProfiles").child(self.loverStoryId!).child("post").updateChildValues([myUuid:1], withCompletionBlock: { (error, ref) in
                                if let err = error{
                                    print(err.localizedDescription)
                                    return
                                }
                                print("good job")
                            })
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
    

    func toggleFlash() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if front == false{
            if (device?.hasTorch)! {
                do {
                    try device?.lockForConfiguration()
                    if (device?.torchMode == AVCaptureTorchMode.on) {
                        device?.torchMode = AVCaptureTorchMode.off
                    } else {
                        do {
                            try device?.setTorchModeOnWithLevel(1.0)
                        } catch {
                            print(error)
                        }
                    }
                    device?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }else{
            print("front flash")
            view.addSubview(flashView!)
        }
    }
    
    func handleFlash(gesture: UITapGestureRecognizer){
        flashEnabled = !flashEnabled
        
        if flashEnabled == true{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash TRUE"), for: .normal)
        }else{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
        }
    }
    
    func dismissOnTap(gesture: UITapGestureRecognizer){
        exitBtn?.removeFromSuperview()
        imageView?.removeFromSuperview()
        player?.pause()
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
    
