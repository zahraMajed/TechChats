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
        keyboardEventListener()
        
        let linkedInImg = UIImage(named: "linkedinIcon")!
        addLeftImgTo(texeField: linkedinURLTF, andImg: linkedInImg)
        let githubImg = UIImage(named: "githubIcon")!
        addLeftImgTo(texeField: githubURLTF, andImg: githubImg)
        
        
    }
    
    func addLeftImgTo(texeField: UITextField, andImg img : UIImage){
        let leftImgView = UIImageView(frame: CGRect(x: 1.0, y: 1.0, width: img.size.width - 1.0, height: img.size.height - 1.0 ))
        leftImgView.image = img
        texeField.leftView = leftImgView
        texeField.leftViewMode = .always
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
    
    func putUserData(){
        guard  let techUser = techUserObj else {
            print("tech user is still nil")
            return
        }
        userNameTF.text = "\(techUser.firstName) \(techUser.lastName)"
        guard let jobTitle = techUser.jobTitle, let userBio = techUser.bio else {
            print("put data function: only user name is exist ")
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
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.userImg.image = image
            }
      }.resume()
    }
    
    func storeProfilePhotoInFBStoarge(with fileName: String){
        guard let userImage1 = userImg.image, let data = userImage1.pngData() else {
            return
        }
        FirebaseStorageClass.uploadProfilePicture(with: data, fileName: fileName) { result in
            switch result {
            case .success(let downloadUrl):
                print("Download URL:",downloadUrl)
            case .failure(let error):
                print("Stoarge error:\(error)")
            }
        }
    }
    
    func getTechUserObj()-> TechUser? {
        if let techUser = techUserObj {
            print("sucessfully get TechUser (inside getTechUSer() edit user)")
            return techUser
        }
        return techUserObj
    }
    
    @IBAction func editPhotoBtnPressed(_ sender: Any) {
        openImagePicker()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let userName = userNameTF.text, let jobTtile = jobTitleTF.text , let userBio = userBioTV.text, let linkedInLink = linkedinURLTF.text, let gitHubLink = githubURLTF.text else {
            return
        }
        let techUser = getTechUserObj()
        guard var userObj = techUser else {
            print("Faild get TechUser inside saveBnt() user edit ")
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
            //update obj value
            userObj.firstName = firstName
            userObj.lastName = lastName
            userObj.jobTitle = jobTtile
            userObj.bio = userBio
            userObj.linkedinLink = linkedInLink
            userObj.gitHubLinked =  gitHubLink
                FirebaseDatabaseClass.updateTechUser(with: userObj) { isUpdated in
                    if isUpdated {
                        //show alert
                        print("Data successfully updated - user edit")
                        //move to profile
                        //store profile photo
                    }else {
                        //show alert - try again
                        print("Faild update data - user edit")
                    }
                }
                storeProfilePhotoInFBStoarge(with: userObj.profilePictureFileName)
            }
            let mainTabBarVC = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
            mainTabBarVC.techUserObj = userObj
            mainTabBarVC.selectedIndex = 1
            self.present(mainTabBarVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        guard let userObj = getTechUserObj() else {
            print("Faild get TechUser inside cancelBtn() user edit ")
            return
        }
        FirebaseDatabaseClass.getTechUserData(with: userObj.safeEmail) { isFetched, userDic in
            if isFetched {
                guard userDic != nil, let userDic = userDic else {
                    print("user dic is nil - inside user edit (cancel)")
                    return
                }
                guard let _ = userDic["first_name"] as? String,
                      let _ = userDic["last_name"] as? String,
                      let _ = userDic["job_title"] as? String,
                      let _ = userDic["user_bio"] as? String
                else {
                    //show alert that forece user to enter jobTitle and bio
                    return
                }
                //then go to profile page
                let mainTabBarVC = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
                mainTabBarVC.techUserObj = userObj
                mainTabBarVC.selectedIndex = 1
                self.present(mainTabBarVC, animated: true, completion: nil)
            }
        }
    }

}

extension UserEditProfileViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
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

extension UserEditProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    
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
}

