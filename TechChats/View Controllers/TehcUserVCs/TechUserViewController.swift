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
    
    func getUserJobTitle(with safeEmail: String) -> String?{
        var jobTitle:String?
        FirebaseDatabaseClass.getTechUserData(with: safeEmail) { isDataFetched, userDic in
            if isDataFetched {
                if let userDic = userDic {
                    jobTitle = userDic["job_title"] as? String
              }
            }
        }
        return jobTitle
    }
    
    func getUserProfilePicture(with profilePictureFileName:String) -> UIImage? {
        var image:UIImage?
        let path =  "images/"+profilePictureFileName
        FirebaseStorageClass.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                image = self.downloadImage(url: url)
            case .failure(let error):
                print("Faild to get dowload URL: \(error)")
            }
        }
        return image
    }
    
    func downloadImage(url:URL) -> UIImage?{
        var image: UIImage?
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            image = UIImage(data: data)
        }.resume()
        return image
    }
}

extension TechUserViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsersarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "userChatCell") as! FriendsTableViewCell
     
        if let userName = allUsersarray[indexPath.row]["name"], let safeEmail = allUsersarray[indexPath.row]["eamil"] {
            cell.lblUserName.text = userName
            
            if let jobTitle = getUserJobTitle(with: safeEmail) {
                cell.lblJobTitle.text = jobTitle
            }
            
            let profilePictureFileName = "\(safeEmail)_profile_picture.png"
            if let userImg = getUserProfilePicture(with: profilePictureFileName) {
                cell.userProfileImg.image = userImg
            }
        }
        return cell
    }
    
}
