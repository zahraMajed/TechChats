//
//  TechUserViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class TechUserViewController: UIViewController {

    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet weak var freindsTableView: UITableView!
    var allUsersarray = [[String:String]]()
    var completion: (([String:String]) -> (Void))?
    //var hasFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freindsTableView.delegate = self
        freindsTableView.dataSource = self
        
        getAllUsers()
        
    }
    
    func getAllUsers(){
        FirebaseDatabaseClass.getAllUsers { result in
            switch result {
            case .success(let usersCollection):
                self.allUsersarray = usersCollection
                self.freindsTableView.reloadData()
            case .failure(let error):
                print("Failed to get users: \(error)")
            }
        }
    }
    
    func getUserJobTitle(with safeEmail: String, completion: @escaping (String) -> Void){
        var jobTitle:String?
        FirebaseDatabaseClass.getTechUserData(with: safeEmail) { isDataFetched, userDic in
            if isDataFetched {
                if let userDic = userDic {
                    jobTitle = userDic["job_title"] as? String
                    completion(jobTitle ?? "")
              }
            }
        }
    }
    
    func getUserProfilePicture(with profilePictureFileName:String, completion: @escaping (UIImage) -> Void) {
        let path =  "images/"+profilePictureFileName
        FirebaseStorageClass.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    let image = UIImage(data: data)
                    completion(image!)
                }.resume()
            case .failure(let error):
                print("Faild to get dowload URL: \(error)")
            }
        }
    }
}

extension TechUserViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsersarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendsTableViewCell
     
        if let userName = allUsersarray[indexPath.row]["name"], let safeEmail = allUsersarray[indexPath.row]["email"] {
            cell.lblUserName.text = userName
            
            self.getUserJobTitle(with: safeEmail) { jobTitle in
                print("\(userName): \(jobTitle)")
                cell.lblJobTitle.text = jobTitle
            }
        
            let profilePictureFileName = "\(safeEmail)_profile_picture.png"
            getUserProfilePicture(with: profilePictureFileName) { userImgData in
                DispatchQueue.main.sync {
                    cell.userProfileImg.image = userImgData
                }
            }
        
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //start conversation
        let targetUser = allUsersarray[indexPath.row]
        print(targetUser)
        performSegue(withIdentifier: "goToChat", sender: targetUser)
            
        //dismiss(animated: true) {[weak self] in
        //self?.completion?(targetUser)
        //}
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            let chatVc = segue.destination as! ChatViewController
            chatVc.isNewConversation = true
    
            let targetUser = sender as! [String:String]
            print(targetUser)
            guard let name = targetUser["name"] , let email = targetUser["email"]  else  {
                print("can not get other user data")
               return
            }
            chatVc.otherUserEmail = email
            chatVc.senderVC = "friends"
            chatVc.title = name
        }
    }
}
