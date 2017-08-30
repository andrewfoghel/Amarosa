//
//  CreateAccountViewController.swift
//  Amarosa
//
//  Created by Sean Perez on 6/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase


class CreateAccountViewController: UIViewController {
    //variables
    var timeStamp: TimeInterval?
    
    //Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var createBtnLbl: UILabel!
    @IBOutlet weak var malebtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var doneBtn: RoundedButton!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTxt: UITextField!
    
    
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordTxt: UITextField!
   
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var nameTxt: UITextField!
    
    @IBOutlet weak var birthdayTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var genderButtons: [UIButton]!
    var datePicker: UDatePicker?
    var genderSelected = false

    
    //Actions
    @IBAction func doneClick(_ sender: Any) {
        let email = emailTxt.text
        let password = passwordTxt.text
        let confirmPassword = confirmPasswordTxt.text
        let name = nameTxt.text
        
        if email == "" || password == "" || name == "" || timeStamp == nil{
            myAlert(title: "Invalid Fields", message: "Please enter value for all fields")
        }else if password != confirmPassword{
            myAlert(title: "Passwords Don't Match", message: "Please make sure that your passwords match")
        }else{
            Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
                if let err = error{
                    self.myAlert(title: "Unable to create account", message: err.localizedDescription)
                    return
                }
                guard let uid = user?.uid else{
                    return
                }
                
                if let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "defaultUser"), 0.5){
                    var uuid = UUID().uuidString
                    Storage.storage().reference().child("user_profile_pictures").child(uuid).putData(imageData, metadata: nil, completion: { (metadata, error) in
                        if let err = error{
                            print(err.localizedDescription)
                            return
                        }
                        
                        if let url = metadata?.downloadURL()?.absoluteString{
                              let userRef = Database.database().reference().child("users").child(uid)
                             let value: [String:AnyObject] = ["name":name as AnyObject,"email":email as AnyObject,"profileImageUrl":url as AnyObject,"birthday":self.timeStamp as AnyObject,"gender":"" as AnyObject]
                             userRef.setValue(value, withCompletionBlock: { (error, ref) in
                             if let err = error{
                             print(err.localizedDescription)
                             return
                             }
                             print("success put to db")
                             self.performSegue(withIdentifier: "camera1", sender: nil)
                             })

                        }
                        
                    })
                }
                
            })
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.iconText = "@"
        emailTextField.errorColor = .red
        emailTextField.delegate = self
        passwordTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        passwordTextField.iconText = "\u{f023}"
        confirmPasswordTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        confirmPasswordTextField.iconText = "\u{f023}"
        nameTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        nameTextField.iconText = "\u{f007}"
        birthdayTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        birthdayTextField.iconText = "\u{f1fd}"
        birthdayTextField.delegate = self
        
        setupUI()
        
        
    }
    
    var scrollViewHeight: CGFloat = 0
    var keyboard = CGRect()
    
    func setupUI(){
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
        
        backBtn.frame =  CGRect(x: width/80, y: width/20, width: width/9.14, height: width/9.14)
        
        createBtnLbl.frame = CGRect(x: 0, y: width/9, width: width, height: width/11)
        
        emailTxt.frame = CGRect(x: width/8, y: createBtnLbl.frame.origin.y + createBtnLbl.frame.size.height + width/16, width: width - width/4, height: width/7.11)
        
        passwordTxt.frame = CGRect(x: width/8, y: emailTxt.frame.origin.y + emailTxt.frame.size.height, width: width - width/4, height: width/7.11)
        
        confirmPasswordTxt.frame = CGRect(x: width/8, y: passwordTxt.frame.origin.y + passwordTxt.frame.size.height, width: width - width/4, height: width/7.11)
        
        otherBtn.frame = CGRect(x: view.frame.midX - width/11.62, y: confirmPasswordTxt.frame.origin.y + confirmPasswordTxt.frame.size.height + width/16, width: width/5.81, height: width/5.81)
        
        malebtn.frame = CGRect(x: view.frame.midX - width/11.62 - width/5.81 - width/12.8, y: confirmPasswordTxt.frame.origin.y + confirmPasswordTxt.frame.size.height + width/16, width: width/5.81, height: width/5.81)
        
        femaleBtn.frame = CGRect(x: view.frame.midX + width/11.62 + width/12.8, y: confirmPasswordTxt.frame.origin.y + confirmPasswordTxt.frame.size.height + width/16, width: width/5.81, height: width/5.81)
        
        nameTxt.frame = CGRect(x: width/8, y: otherBtn.frame.origin.y + otherBtn.frame.size.height, width: width - width/4, height: width/7.11)
        
        birthdayTextField.frame = CGRect(x: width/8, y: nameTxt.frame.origin.y + nameTxt.frame.size.height, width: width - width/4, height: width/7.11)
        
        doneBtn.frame = CGRect(x: self.view.frame.midX - width/3.2, y: height - width/9 - width/20, width: width/1.6, height: width/9)
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
    
    
    @IBAction func genderSelected(_ sender: Any) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            return
        }
        if genderSelected {
            genderButtons.forEach { $0.isSelected = false }
        }
        button.isSelected = true
        genderSelected = true
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showDatePicker() {
        if datePicker == nil {
            datePicker = UDatePicker(frame: view.frame, willDisappear: { date in
                if date != nil {
                    self.timeStamp = date?.timeIntervalSince1970
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    self.birthdayTextField.text = dateFormatter.string(from: date!)
                }
            })
        }
        datePicker?.picker.date = Date()
        datePicker?.present(self)
    }
    
    func myAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }


}

extension CreateAccountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if (text.characters.count < 3 || !text.contains("@")) {
                    floatingLabelTextField.errorMessage = "Invalid email"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == birthdayTextField {
            textField.resignFirstResponder()
            showDatePicker()
        }
    }
}
