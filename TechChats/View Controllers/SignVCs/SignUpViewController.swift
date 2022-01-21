//
//  SignUpViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var userObj:TechUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        
        keyboardEventListener()

    }
    
    deinit {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    func keyboardEventListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func signupBtnPressed(_ sender: UIButton) {
        if let firstName = firstNameTF.text, let lastName = lastNameTF.text, let email = emailTF.text, let password = passwordTF.text {
            var emptyFieldArray = [String]()
            var missingFiled = ""
            if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty {
                if firstName.isEmpty {
                    emptyFieldArray.append("first name")
                }
                if lastName.isEmpty {
                    emptyFieldArray.append("last name")
                }
                if email.isEmpty{
                    emptyFieldArray.append("email")
                }
                if password.isEmpty{
                    emptyFieldArray.append("password")
                }
                for i in emptyFieldArray {
                    if i != emptyFieldArray.last! {
                        missingFiled += "\(i),"
                    } else if i == emptyFieldArray.last! {
                        if emptyFieldArray.count > 1 {
                            missingFiled += "and \(i)"
                        } else {
                            missingFiled += "\(i)"
                        }
                    }
                }
                if emptyFieldArray.count == 4 {
                    SwiftEntryClass.showTryAgainAlertWith(title: "Signup Faild", textDescription: "Please fill all field")
                    return
                }else if !emptyFieldArray.isEmpty {
                    SwiftEntryClass.showTryAgainAlertWith(title: "Signup Faild", textDescription: "Please enter your \(missingFiled)")
                    return
                }
            }
            
            FirebaseAuthClass.signUserUp(firstName: firstName, lastName: lastName, email: email, password: password) { isExist, isSignedUp, errorInfo, techUSerObj in
                if isExist {
                    //show slert here or label that user is exist
                    print("user already exist")
                    return
                } else if !isExist {
                    if !isSignedUp {
                        SwiftEntryClass.showTryAgainAlertWith(title: "Signup Faild", textDescription: "\(errorInfo!)")
                        print("Faild to create a user - \(errorInfo!)")
                        return
                    }else
                    if isSignedUp {
                        //show success alert here
                        print("User has signed up successfully")
                        
                        if let techUserObj = techUSerObj {
                            self.userObj = techUserObj
                            print(self.userObj!)
                            print("in btn pressed")
                        }
                        
                        let editProfileNav = self.storyboard?.instantiateViewController(identifier: "editProfileNav") as! UINavigationController
                        let editProfile = editProfileNav.topViewController as! UserEditProfileViewController
                        if let techUserObj = techUSerObj {
                            editProfile.techUserObj = techUserObj
                            print(editProfile.techUserObj!)
                            print("in btn pressed")
                        }
                        self.present(editProfileNav, animated: true, completion: nil)
                    }//end last else if
                }
            }
        }
        hideKeyboard()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard(){
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
        
    }
}
