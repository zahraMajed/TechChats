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
            let signinVC = storyboard?.instantiateViewController(identifier: "signinVC")
            self.present(signinVC!, animated: true, completion: nil)
        }else {
            
            let recentChatsVC = storyboard?.instantiateViewController(identifier: "mainTabBar")
            self.present(recentChatsVC!, animated: true, completion: nil)
        }
    }


}
