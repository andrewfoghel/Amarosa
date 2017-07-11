//
//  SignInViewController.swift
//  Amarosa
//
//  Created by Sean Perez on 6/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate {

    //Variables
    let faceLoginButton = FBSDKLoginButton()

    
    //Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signInBtn: RoundedButton!
    @IBOutlet weak var createBtn: BorderedButton!
    @IBOutlet weak var amarosaLbl: UIImageView!
    //Actions
    //Firebase email login
    @IBAction func signInBtnClick(_ sender: Any) {
        let email = emailTxt.text
        let password = passwordTxt.text
        
        if email == "" || password == ""{
            self.myAlert(title: "Empty Fields", message: "Please fill in all fields")
        }else{
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                    if let err = error{
                    self.myAlert(title: "Unable to Login", message: err.localizedDescription)
                    return
                }
                print("successful login to firebase")
                    //performSegue() to cameraVC
                self.performSegue(withIdentifier: "message", sender: nil)
            }
        }
        
    }
    
    fileprivate func setupFacebookBtn(){
        //get access to the fb with the login button
        
        let width = self.view.frame.size.width
        view.addSubview(faceLoginButton)

        /*faceLoginButton.frame = CGRect(x: signInBtn.frame.origin.x, y: signInBtn.frame.origin.y + width/5.33,width: signInBtn.frame.size.width, height: signInBtn.frame.size.height)*/
        faceLoginButton.frame = CGRect(x: 10000, y: signInBtn.frame.origin.y + width/5.33,width: signInBtn.frame.size.width, height: signInBtn.frame.size.height)
        faceLoginButton.layer.cornerRadius = 20
        faceLoginButton.layer.masksToBounds = true
        faceLoginButton.delegate = self
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 20, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            self.faceLoginButton.frame = CGRect(x: self.signInBtn.frame.origin.x
                , y: self.signInBtn.frame.origin.y + width/5.33,width: self.view.frame.size.width - self.signInBtn.frame.origin.x*2, height: self.signInBtn.frame.size.height)
        }, completion: nil)
        
        
        //needs to be an array
        faceLoginButton.readPermissions = ["email", "public_profile"]
        
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error.localizedDescription)
            
        }else{
            print("Successfully logged in with facebook")
            //initialze a facebook grab request
            showEmail()
            performSegue(withIdentifier: "message", sender: nil)
        }
    }
    
    func showEmail() {
        //logging into fire base with facebook credentials
        let accessToken = FBSDKAccessToken.current()
        let currentFacebookUser = FBSDKLoginManager()
        guard let accessTokenString = accessToken?.tokenString else{
            return
        }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error{
                print("something is wrong with firebase login",error ?? "")
                self.myAlert(title: "Unable to Login", message: err.localizedDescription)
                currentFacebookUser.logOut()
                return
            }
            
            
            
            
            if let uid = user?.uid{
                
                let userRef = Database.database().reference().child("users").child(uid)
                let pictureRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"picture.type(large)"])
                let _ = pictureRequest?.start(completionHandler: { (connection, result, error) in
                    guard let userInfo = result as? [String: Any] else {
                        print("unable to get photo url")
                        return}
                    
                    if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        //  self.downloadImage(url: imageURL)
                        
                        let url = URL(string: imageURL)
                        
                        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                            
                            DispatchQueue.main.async {
                                
                                if let image = UIImage(data: data!){
                                    
                                    if let uploadData = UIImageJPEGRepresentation(image, 0.5){
                                        let imageUrl = NSUUID().uuidString

                                        Storage.storage().reference().child("user_profile_pictures").child(imageUrl).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                            if let err = error{
                                                print("Unable to find image from facebook ",err.localizedDescription)
                                                return
                                            }
                                            if let facebookImageUrl = metadata?.downloadURL()?.absoluteString{
                                                let values:[String:AnyObject] = ["name":user?.displayName as AnyObject,"email":user?.email as AnyObject,"profileImageUrl":facebookImageUrl as AnyObject,"birthday":"" as AnyObject,"gender":"" as AnyObject]
                                                userRef.setValue(values)
                                            }
                                        })
                                        
                                        
                                    }
                                }
                            }
                        }
                        task.resume()
                        
                    }
                })
                
            }

            print("successfully logged into fire base", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, gender"]).start(completionHandler: { (connection, result, err) in
            
            if err != nil{
                print("Failed to start the graph request",err ?? "")
            }
            print(result ?? "")
        })
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFacebookBtn()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func myAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
