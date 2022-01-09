//
//  UserEditProfileViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class UserEditProfileViewController: UIViewController {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var jobTitleTF: UITextField!
    @IBOutlet weak var userBioTV: UITextView!
    @IBOutlet weak var linkedinURLTF: UITextField!
    @IBOutlet weak var githubURLTF: UITextField!
    var techUserObj:TechUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTF.delegate = self
        jobTitleTF.delegate = self
        userBioTV.delegate = self
        linkedinURLTF.delegate = self
        githubURLTF.delegate = self
        userBioTV.layer.borderWidth = 0.5
        userBioTV.text = "Bio"
        userBioTV.textColor = UIColor.lightGray
        
        print("inside edit profile")
        
        putUserData()
        
        
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
    
    func putUserData(){
        
        guard  let techUser = techUserObj else {
            print("tech user is still nil")
            return
        }
        userNameTF.text = "\(techUser.firstName) \(techUser.lastName)"
        
        guard let jobTitle = techUser.jobTitle, let userBio = techUser.bio else {
            print("put data: only user name is exist ")
            return
        }
        
        jobTitleTF.text = jobTitle
        userBioTV.text = userBio
        
        if let linkedinLink = techUser.linkedinLink {
            linkedinURLTF.text = linkedinLink
        }
        
        if let gitHunLink = techUser.gitHubLinked {
            githubURLTF.text = gitHunLink
        }
        
        // set photo
        getUserProfilePicture(with: techUser.profilePictureFileName)
    }
    
    func getUserProfilePicture(with profilePictureFileName:String){
        let path =  "images/"+profilePictureFileName
        FirebaseStorageClass.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                self.downloadImage(url: url)
            case .failure(let error):
                self.storeProfilePhotoInFBStoarge(with: profilePictureFileName)
                self.putUserData()
                print("Faild to get dowload URL: \(error)")
            }
        }
    }
    
    func downloadImage(url:URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.sync {
                let image = UIImage(data: data)
                self.userImg.image = image
            }
      }.resume()
    }
    
    func getTechUserObj()-> TechUser? {
        if let techUser = techUserObj {
            print("sucessfully get TechUser (inside getTechUSer() )")
            return techUser
        }
        return techUserObj
    }
    
    @IBAction func editPhotoBtnPressed(_ sender: Any) {
        openImagePicker()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        guard let userName = userNameTF.text, let jobTtile = jobTitleTF.text , let userBio = userBioTV.text,
              let linkedInLink = linkedinURLTF.text, let gitHubLink = githubURLTF.text else {
            return
        }

            let techUser = getTechUserObj()
            guard var userObj = techUser else {
                print("Faild get TechUser (inside saveBnt() ")
                return
            }
            
            if userName.isEmpty && jobTtile.isEmpty && userBio.isEmpty {
                //show alert to complete the reqierd
                print("Please compleate missing fialds")
            } else {
    
                
                var components = userName.components(separatedBy: " ")
                if components.count > 0 {
                let firstName = components.removeFirst()
                let lastName = components.joined(separator: " ")
                     
                userObj.firstName = firstName
                userObj.lastName = lastName
                userObj.jobTitle = jobTtile
                userObj.bio = userBio
                userObj.linkedinLink = linkedInLink
                userObj.gitHubLinked =  gitHubLink
                
                    FirebaseDatabaseClass.updateTechUser(with: userObj) { isUpdated in
                        if isUpdated {
                            //show alert
                            print("updated inside completion ")
                        }else {
                            //show alert
                            print("Faild updated inside completion ")
                        }
                    }
                
                storeProfilePhotoInFBStoarge(with: userObj.profilePictureFileName)
          }
            // alert that data saved successfull
                
            let mainTabBarVC = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
            mainTabBarVC.techUserObj = userObj
            mainTabBarVC.selectedIndex = 1
            self.present(mainTabBarVC, animated: true, completion: nil)
         
            }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        //then go to profile page
        //first check if jobTitle and bio is stored in fireBase you have to user obser
        // if thay stored then show conformation then got to profile page without updating anything
        // if nothing stored in FB then show alert and forece user to enter jobTitle and bio
    }
    
    func storeProfilePhotoInFBStoarge(with fileName: String){
        
        guard let userImage1 = userImg.image, let data = userImage1.pngData() else {
            return
        }
        
        FirebaseStorageClass.uploadProfilePicture(with: data, fileName: fileName) { result in
            switch result {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print(downloadUrl)
            case .failure(let error):
                print("Stoarge error:\(error)")
            }
        }
    }
    
    
    }
    


extension UserEditProfileViewController: UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard(){
        userNameTF.resignFirstResponder()
        jobTitleTF.resignFirstResponder()
        userBioTV.resignFirstResponder()
        linkedinURLTF.resignFirstResponder()
        linkedinURLTF.resignFirstResponder()
        githubURLTF.resignFirstResponder()
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func openImagePicker() {
            print("inside getPhoto()")
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       dismiss(animated: true, completion: nil)
        if let img = info[.originalImage] as? UIImage {
            userImg.image = img
            print("img assigned")
        }else {
            print("img not found")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

