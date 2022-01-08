//
//  UserProfileViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    var linkedinLink:String?
    var gitHunLink:String?
    var techUserObj:TechUser? // i will get it from tabBarVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfileData()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotToEditProfile" {
            let userEditProfileVC = segue.destination as! UserEditProfileViewController
            techUserObj = getTechUserObj()
            if let techUserObj = techUserObj {
                print("tech user in profile from tabBar \(techUserObj)")
                userEditProfileVC.techUserObj = techUserObj
            }else {
                print("Faild to get techUSer from tabBarVC")
            }
        }
    }
    
    func getTechUserObj()-> TechUser? {
        let mainTabBar = tabBarController as! mainTabBarC
        techUserObj = mainTabBar.techUserObj
        if let techUser = techUserObj {
            print("sucessfully get TechUser (inside getTechUSer() profile)")
            return techUser
        }
        return techUserObj
    }
    
    func getProfileData(){
        techUserObj = getTechUserObj()
        guard let userObj = techUserObj else {
            print("Can not get profile data")
            return
        }
        
        FirebaseDatabaseClass.getTechUserData(with: userObj.safeEmail) { isDataFetched, userDic in
            if isDataFetched {
                if let userDic = userDic {
                    let userName = "\(String(describing: userDic["first_name"])) \(String(describing: userDic["last_name"]))"
                    self.lblUserName.text = userName
                    self.lblJobTitle.text = userDic["job_title"] as? String
                    self.lblBio.text = userDic["user_bio"] as? String
                    self.linkedinLink = userDic["linkedin_link"] as? String
                    self.gitHunLink = userDic["github_link"] as? String
              }
            }
        }
        
        //fetch photo
    }
    
    @IBAction func signoutBtnPressed(_ sender: Any) {
        
        //before that show conformation alert
        
        FirebaseAuthClass.signUserOut { isSignedOut in
            if isSignedOut {
                let signinVC = self.storyboard?.instantiateViewController(identifier: "signinVC")
                self.present(signinVC!, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        //alert with email
    }
    
    @IBAction func linkedinBtnPressed(_ sender: Any) {
        //alert with linkedin
    }
    
    @IBAction func githubBtnPressed(_ sender: Any) {
        //alert with githun link
    }
    
    
}
