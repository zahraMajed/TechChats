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
            let destination = segue.destination as! UINavigationController
            let userEditProfileVC = destination.topViewController as! UserEditProfileViewController
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
                    let userName = "\(userDic["first_name"] as! String ) \(userDic["last_name"] as! String)"
                    self.lblUserName.text = userName
                    self.lblJobTitle.text = userDic["job_title"] as? String
                    self.lblBio.text = userDic["user_bio"] as? String
                    self.linkedinLink = userDic["linkedin_link"] as? String
                    self.gitHunLink = userDic["github_link"] as? String
              }
            }
        }
    
        self.getUserProfilePicture(with: userObj.profilePictureFileName)
    }
    
    func getUserProfilePicture(with profilePictureFileName:String){
        let path =  "images/"+profilePictureFileName
        FirebaseStorageClass.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                self.downloadImage(url: url)
            case .failure(let error):
                print("Faild to get dowload URL: \(error)")
            }
        }
    }
    
    func downloadImage(url:URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.userImg.image = image
            }
      }.resume()
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
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
            return
        }
        SwiftEntryClass.showOKAlertWith(title: "Email", textDescription: currentUserEmail)
    }
    
    @IBAction func linkedinBtnPressed(_ sender: Any) {
        //alert with linkedin
        guard let linkedinLink = linkedinLink, linkedinLink != "" || !linkedinLink.isEmpty else {
            SwiftEntryClass.showOKAlertWith(title: "Linkedin", textDescription: "No linkedin link")
            return
        }
        SwiftEntryClass.showOKAlertWith(title: "Linkedin", textDescription: linkedinLink)
    }
    
    @IBAction func githubBtnPressed(_ sender: Any) {
        //alert with githun link
        guard let gitHunLink = gitHunLink, gitHunLink != "" || !gitHunLink.isEmpty else {
            SwiftEntryClass.showOKAlertWith(title: "Github", textDescription: "No Github link")
            return
        }
        SwiftEntryClass.showOKAlertWith(title: "Github", textDescription: gitHunLink)
    }
    
}
