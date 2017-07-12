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


class CameraViewController: SwiftyCamViewController,SwiftyCamViewControllerDelegate{

    //Variables
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    var flashBtn: UIButton?
    var imageView: UIImageView?
    var exitBtn: UIButton?
    var postBtn: UIButton?
    //Outlets
    
    
    //Actions
    
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        defaultCamera = .front
        cameraDelegate = self
       
        swipeToZoom = false
        
        setupCaptureBtn()
        setupFlashBtn()

    }

    //Capture Button Set Up
    func setupCaptureBtn(){
        let captureBtn = SwiftyCamButton(frame: CGRect(x: self.view.frame.midX - width/9.84, y: height - width/4.92 - 8, width: width/4.92, height: width/4.92))
        captureBtn.delegate = self
        captureBtn.setImage(#imageLiteral(resourceName: "captureBtn"), for: .normal)
        captureBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePhoto)))
        captureBtn.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleVideo)))
        view.addSubview(captureBtn)
    }
    
    
    //Post Photo to FireBase
    func handlePostPhoto(gesture: UITapGestureRecognizer){
        let uuid = UUID().uuidString
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        if let image = imageView?.image{
            if let data = UIImageJPEGRepresentation(image, 0.5){
                Storage.storage().reference().child("love-story-photos").child(uuid).putData(data, metadata: nil, completion: { (metadata, error ) in
                    if let err = error{
                        print(err.localizedDescription)
                        return
                    }
                    
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        Database.database().reference().child("loveStories").child(uid).childByAutoId().setValue(["storyImageUrl":downloadURL], withCompletionBlock: {(error, ref) in
                            if let err = error{
                                print(err.localizedDescription)
                                return
                            }
                            
                            self.exitBtn?.removeFromSuperview()
                            self.postBtn?.removeFromSuperview()
                            self.imageView?.removeFromSuperview()
                            
                        })
                    }
                    
                })
            }
        }
    }
    
    
    
    //Flash Button Set Up
    func setupFlashBtn(){

        flashBtn = UIButton(frame: CGRect(x: 8, y: 16, width: width/8.27, height: width/8.27))
        flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
        flashBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFlash)))
        view.addSubview(flashBtn!)
    }
    
    //set flash
    func handleFlash(gesture: UITapGestureRecognizer){
        flashEnabled = !flashEnabled
        
        if flashEnabled == true{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash TRUE"), for: .normal)
        }else{
            flashBtn?.setImage(#imageLiteral(resourceName: "Flash FALSE"), for: .normal)
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        imageView = UIImageView(image: photo)
        imageView?.frame = self.view.frame
        exitBtn = UIButton(frame: CGRect(x: 8, y: 16, width: width/8.27, height: width/8.27))
        exitBtn?.setTitle("X", for: .normal)
        exitBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
        exitBtn?.layer.zPosition = 3
        postBtn = UIButton(frame: CGRect(x: self.view.frame.width - width/7.27 - 8, y: height - width/7.27, width: width/7.27, height: width/7.27))
        postBtn?.setTitle("POST!!", for: .normal)
        postBtn?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostPhoto)))
        postBtn?.layer.zPosition = 3
        view.addSubview(exitBtn!)
        view.addSubview(imageView!)
        view.addSubview(postBtn!)
    }

    func dismissOnTap(gesture: UITapGestureRecognizer){
        exitBtn?.removeFromSuperview()
        imageView?.removeFromSuperview()
    }
    
    //set video
    func handleVideo(gesture: UILongPressGestureRecognizer){
        switch gesture.state{
        case .began:
            startVideoRecording()
            break
        case .ended:
            stopVideoRecording()
            break
        default:
            break
        }
    }

    

}
