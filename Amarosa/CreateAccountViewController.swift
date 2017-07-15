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
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTxt: UITextField!
    
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
        let name = nameTxt.text
        
        if email == "" || password == "" || name == "" || timeStamp == nil{
            myAlert(title: "Invalid Fields", message: "Please Enter Value for all fields")
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
        nameTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        nameTextField.iconText = "\u{f007}"
        birthdayTextField.iconFont = UIFont(name: "FontAwesome", size: 15)
        birthdayTextField.iconText = "\u{f1fd}"
        birthdayTextField.delegate = self
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
