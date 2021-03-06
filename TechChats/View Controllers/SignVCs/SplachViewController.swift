//
//  SplachViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth

class SplachViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if FirebaseAuth.Auth.auth().currentUser == nil {
            
            let signinVC = self.storyboard?.instantiateViewController(identifier: "signinVC")
            self.dismiss(animated: true, completion: nil)
            self.present(signinVC!, animated: true, completion: nil)
            
        }else
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            
            let mainTabBarToChat = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
            guard let userEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
               print("user email is nil in splach")
                return
           }
            FirebaseDatabaseClass.getTechUserObj(with: userEmail) { techUser in
                print(" inside splach: \(techUser)")
                mainTabBarToChat.techUserObj = techUser
            }
            mainTabBarToChat.selectedIndex = 0
            self.dismiss(animated: true, completion: nil)
            self.present(mainTabBarToChat, animated: true, completion: nil)
        }
    }


}
