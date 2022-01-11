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
        
        //listen for keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func signupBtnPressed(_ sender: UIButton) {
        if let firstName = firstNameTF.text, let lastName = lastNameTF.text, let email = emailTF.text, let password = passwordTF.text {
            
            if firstName.isEmpty && lastName.isEmpty && email.isEmpty && password.isEmpty {
                //alert here
                print("Please fil all entries")
                return
            }
            
            FirebaseAuthClass.signUserUp(firstName: firstName, lastName: lastName, email: email, password: password) { isExist, isSignedUp, errorInfo, techUSerObj in
                if isExist {
                    //user exist
                    //show slert here that user is exist
                    print("user already exist")
                    return
                } else if !isExist {
                    if !isSignedUp {
                        //show alert here with error info
                        print("Faild to create a user - \(errorInfo!)")
                        return
                    }else
                    if isSignedUp {
                        //show alert here
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
                        
                        //self.performSegue(withIdentifier: "goToeditProfileNav", sender: self.signupBtnPressed(_:))
                        
                    }//end last else if
                }
            }
        }
        hideKeyboard()
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToeditProfileNav" {
            let destination = segue.destination as! UINavigationController
            let editProfile = destination.topViewController as! UserEditProfileViewController
            if let user = userObj {
                print(" in prepare")
                editProfile.techUserObj = user
                print(editProfile.techUserObj!)
            }
            
        }
    }*/
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
