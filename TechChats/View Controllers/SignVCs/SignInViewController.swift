//
//  SignInViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import SwiftEntryKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func signinBtnPressed(_ sender: Any) {
        if let userEmail = emailTF.text, let userPasaword = passwordTF.text {
            FirebaseAuthClass.signUserIn(email: userEmail, password: userPasaword) { isSigedin in
                if isSigedin {
                    
                    print("User has signed in successfully")
                    
                    let mainTabBarToChat = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
                    FirebaseDatabaseClass.getTechUserObj(with: userEmail) { techUser in
                        print(" inside signin: \(techUser)")
                        mainTabBarToChat.techUserObj = techUser
                    }
                    mainTabBarToChat.selectedIndex = 0
                    self.dismiss(animated: true, completion: nil)
                    self.present(mainTabBarToChat, animated: true, completion: nil)
            
                }else if !isSigedin {
                    if userEmail.isEmpty  {
                        //show label here
                        print("Please enter your email")
                        return
                    }
                    if userPasaword.isEmpty {
                        //show label here
                        print("Please enter your password")
                        return
                    }
                    //show alert
                    SwiftEntryClass.showTryAgainAlertWith(title: "Signin Faild", textDescription: "Looks like your email and/or password do not match")
                    print("Signin Faild, Your email and/or password do not match. try again")
                }
            }
        }}
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard(){
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
