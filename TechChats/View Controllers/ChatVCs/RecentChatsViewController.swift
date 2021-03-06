//
//  RecentChatsViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class RecentChatsViewController: UIViewController {
    
    
    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet weak var recentChatsTableView: UITableView!
    
    var conversationsArray = [Conversation]()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        recentChatsTableView.dataSource = self
        recentChatsTableView.delegate = self
     
        startListeningForConversations()
    }
    
    func startListeningForConversations(){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
            return
        }
        var currentUserEmailSafe = currentUserEmail.replacingOccurrences(of: ".", with: "-")
        currentUserEmailSafe =  currentUserEmailSafe.replacingOccurrences(of: "@", with: "-")
        
        print("starting conversation fetch...")
        //there is ovserver
        
        FirebaseDatabaseClass.getAllConversation(for: currentUserEmailSafe) { result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self.conversationsArray = conversations
                DispatchQueue.main.async {
                    self.recentChatsTableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get convo: \(error)")
                
            }
        }
    }

    
}

extension RecentChatsViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "userChatCell") as! RecentChatTableViewCell
        cell.lblUserName.text = conversationsArray[indexPath.row].name
        cell.lblUserChat.text = conversationsArray[indexPath.row].latestMessage.text
        let path = "images/\(conversationsArray[indexPath.row].otherUserEmail)_profile_picture.png"
        FirebaseStorageClass.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        cell.userImg.image = image
                    }
              }.resume()
            case .failure(let error):
                print("Faild to get photo in recent chat \(error)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
              let model = conversationsArray[indexPath.row]
              openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController() /////////////////here
        vc.title = model.name
        vc.otherUserEmail = model.otherUserEmail
        vc.conversationId = model.id
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return .delete
       }

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // begin delete
               let conversationId = conversations[indexPath.row].id
               tableView.beginUpdates()
               self.conversations.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .left)

               DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                   if !success {
                       // add model and row back and show error alert
                   }
               })

               tableView.endUpdates()
           }
     */
    
}

