//
//  SignInViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signinBtnPressed(_ sender: Any) {
        if let userEmail = emailTF.text, let userPasaword = passwordTF.text {
            FirebaseAuthClass.signUserIn(email: userEmail, password: userPasaword) { isSigedin in
                if isSigedin {
                    print("User has signed in successfully")
                    self.dismiss(animated: true, completion: nil)
                    let recentChatsVC = self.storyboard?.instantiateViewController(identifier: "recentChatVC")
                    self.present(recentChatsVC!, animated: true, completion: nil)
                }else if !isSigedin {
                    if userEmail.isEmpty, userPasaword.isEmpty {
                        //show alert here
                        print("alert user did not enter signin data")
                    }
                }
            }
        }}
    

}
