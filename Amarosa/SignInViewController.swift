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
    
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var createAccountImage: UIImageView!
    
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
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
                
                Database.database().reference().child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject]{
                        let lovePageId = dictionary["lovePage"]
                        if lovePageId == nil{
                            self.performSegue(withIdentifier: "camera", sender: nil)
                        }else{
                            self.performSegue(withIdentifier: "camera1", sender: nil)

                        }
                    }
                })
                
            }
        }
        
    }
    
    fileprivate func setupFacebookBtn(){
        //get access to the fb with the login button
        
        let width = self.view.frame.size.width
        scrollView.addSubview(faceLoginButton)

        /*faceLoginButton.frame = CGRect(x: signInBtn.frame.origin.x, y: signInBtn.frame.origin.y + width/5.33,width: signInBtn.frame.size.width, height: signInBtn.frame.size.height)*/
        faceLoginButton.frame = CGRect(x: width, y: signInBtn.frame.origin.y + width/5.33,width: signInBtn.frame.size.width, height: signInBtn.frame.size.height)
        faceLoginButton.layer.cornerRadius = faceLoginButton.frame.size.height/2
        faceLoginButton.layer.masksToBounds = true
        faceLoginButton.delegate = self
        
        UIView.animate(withDuration: 1, delay: 0.5, animations: {
            self.faceLoginButton.frame = CGRect(x: self.signInBtn.frame.origin.x
                , y: self.signInBtn.frame.origin.y + width/5.33,width: self.view.frame.size.width - self.signInBtn.frame.origin.x*2, height: self.signInBtn.frame.size.height)
        })
        
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
                                                let values:[String:AnyObject] = ["name":user?.displayName as AnyObject,"email":user?.email as AnyObject,"profileImageUrl":facebookImageUrl as AnyObject,"birthday":836188340 as AnyObject,"gender":"" as AnyObject]
                                                userRef.updateChildValues(values)
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

            Database.database().reference().child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let lovePageId = dictionary["lovePage"]
                    if lovePageId == nil{
                        self.performSegue(withIdentifier: "camera", sender: nil)
                    }else{
                        self.performSegue(withIdentifier: "camera1", sender: nil)
                    }
                }
            })
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
        
        setupUI()
        setupFacebookBtn()
        
    }
    
    var scrollViewHeight: CGFloat = 0
     var keyboard = CGRect()
    
    func setupUI(){
        view.backgroundColor = UIColor(red: 0.99, green: 0.56, blue: 0.28, alpha: 1)
        
        scrollView.frame = view.frame
        scrollView.contentSize.height = view.frame.size.height
        scrollViewHeight = scrollView.frame.size.height
        scrollView.alwaysBounceVertical = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        amarosaLbl.frame = CGRect(x: view.frame.midX - width/4, y: width/3, width: width/2, height: width/16)
        
        emailTxt.frame = CGRect(x: width/8, y: amarosaLbl.frame.origin.y + amarosaLbl.frame.height + width/3.2, width: width - width/4, height: width/10.67)
        
        passwordTxt.frame = CGRect(x: width/8, y: emailTxt.frame.origin.y + emailTxt.frame.height + width/32, width: width - width/4, height: width/10.67)
        
        forgotBtn.frame = CGRect(x: passwordTxt.frame.origin.x + passwordTxt.frame.size.width + width/64, y: passwordTxt.frame.origin.y + width/106.67, width: width/12.8, height: width/12.8)
        
        signInBtn.frame = CGRect(x: width/10, y: passwordTxt.frame.origin.y + passwordTxt.frame.size.height + width/8, width: width - width/5, height: width/8)
        
        createBtn.frame = CGRect(x: width/10, y: signInBtn.frame.origin.y + 2*signInBtn.frame.size.height + width/5.33, width: width - width/5, height: width/8)
        createBtn.layer.cornerRadius = createBtn.frame.size.height/2
        createBtn.layer.masksToBounds = true
        
        termsLbl.frame = CGRect(x: 0, y: createBtn.frame.origin.y + createBtn.frame.height + width/12.8, width: width, height: width/21.33)
       
        createAccountImage.frame = CGRect(x: createBtn.frame.origin.x + width/16, y: createBtn.frame.origin.y + width/32, width: width/16, height: width/16)
    }

    
    func showKeyboard(_ notification:Notification){
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        })
    }
    
    func hideKeyboard(_ recoginizer:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        })
    }
    
    func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    
    func myAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
