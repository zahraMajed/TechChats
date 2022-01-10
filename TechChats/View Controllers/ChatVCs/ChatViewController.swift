//
//  ChatViewController.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL:String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController  {
    
    static var dataFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.timeStyle = .long
        return formatter
    }
    
    var otherUserEmail:String?
    var senderVC:String?
    var isNewConversation = false
    
    var messages = [Message]()
    var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email")  as? String else {
            return nil
        }
        return Sender(photoURL: "", senderId: email , displayName: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.dataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        guard let senderVC = senderVC else {
            return
        }
        let mainTabBarToChat = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! mainTabBarC
        if senderVC == "friends" {
            //go back to friend
            mainTabBarToChat.selectedIndex = 2
        }else if senderVC == "recentChats" {
            //go back to recent chat
            mainTabBarToChat.selectedIndex = 0
        }
        self.present(mainTabBarToChat, animated: true, completion: nil)
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender,
             let messageId = createMsgID() else {
            return
        }
        
        //send msg
        if isNewConversation {
            // create convo in database
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            guard let otherUserEmail = otherUserEmail else {
                return
            }
            
            FirebaseDatabaseClass.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { success in
                if success {
                    print("Message sent")
                }else {
                    print("Faild to send")
                }
            }
        }else {
            //append to exiting convo data
        }
        
    }
    
    func createMsgID() -> String? {
        // data, otherUserEmail, senderEmail, randomInt
        let dateString = Self.dataFormatter.string(from: Date())
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
            return nil
        }
        
        var currentUserEmailSafe = currentUserEmail.replacingOccurrences(of: ".", with: "-")
        currentUserEmailSafe =  currentUserEmailSafe.replacingOccurrences(of: "@", with: "-")
        
        let newIdentifier = "\(otherUserEmail!)_\(currentUserEmailSafe)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("self sender is nil - email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension MessageKind {
    var msgKindString: String {
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
