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
    var conversationId: String? // if converation created
    var isNewConversation = false
    var messagesArray = [Message]()
    var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email")  as? String else {
            return nil
        }
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        return Sender(photoURL: "", senderId: safeEmail , displayName: "Me") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        //messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversaionID = conversationId {
            listernForMessages(conversationId: conversaionID, shouldScrollToBottom:true)
        }
    }
    
    func listernForMessages(conversationId: String, shouldScrollToBottom:Bool){
        FirebaseDatabaseClass.getAllMessagesForConversation(with: conversationId) { result in
            switch result {
                       case .success(let messages):
                           print("success in getting messages: \(messages)")
                           guard !messages.isEmpty else {
                               print("messages are empty")
                               return
                           }
                        self.messagesArray = messages
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadDataAndKeepOffset()

                            if shouldScrollToBottom {
                                self.messagesCollectionView.scrollToBottom()
                            }
                        }
                       case .failure(let error):
                           print("failed to get messages: \(error)")
            }
        }
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
            
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender,
             let messageId = createMsgID() else {
            return
        }
        
        //send msg
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            // create convo in database
            guard let otherUserEmail = otherUserEmail else {
                return
            }
            FirebaseDatabaseClass.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { success in
                if success {
                    print("Message sent")
                    self.isNewConversation = false
                    let newConversaionId = "conversation_\(message.messageId)"
                    self.conversationId = newConversaionId
                    self.listernForMessages(conversationId: newConversaionId, shouldScrollToBottom: true)
                    self.messageInputBar.inputTextView.text = nil
                }else {
                    print("Faild to send")
                }
            }
        }else {
            //append to exiting convo data
            guard let conversationID = conversationId, let otherUserEmail = otherUserEmail , let name = self.title  else {
                return
            }
            FirebaseDatabaseClass.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name:name , newMessage: message) { success in
                if success {
                    print("message sent")
                    self.messageInputBar.inputTextView.text = nil
                }else {
                    print("Faild to sent")
                }
            }
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
        return messagesArray[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesArray.count
    }
    
}

