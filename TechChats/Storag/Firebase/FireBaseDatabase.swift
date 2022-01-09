//
//  FireBaseDatabase.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import Foundation
import FirebaseDatabase

final class FirebaseDatabaseClass {
    
    static let databaseRef = Database.database().reference()
    
    static func checkExistenceOfUser(with email: String, completion: @escaping ( (Bool) -> Void) ) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        
        databaseRef.child(safeEmail).observeSingleEvent(of: .value) { dataSnapshot in
            guard dataSnapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    static func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void ){
        databaseRef.child("users").observeSingleEvent(of: .value) { dataSnapshot in
            guard let collection = dataSnapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.faildToFetch))
                return
            }
            completion(.success(collection))
        }
    }
    
    public enum DatabaseError:Error{
        case faildToFetch
    }
    
    static func getTechUserData(with safeEmail:String, completion: @escaping (_ isFetched: Bool, _ userValeDic:NSDictionary?) -> Void){
        databaseRef.child(safeEmail).observeSingleEvent(of: .value) { dataSnapshot in
            guard let value = dataSnapshot.value as? NSDictionary else {
                print("Fail to fetch data")
                completion(false,nil)
                return
            }
            completion(true, value)
        }
    }
    
    static func getTechUserObj(with email:String, completion: @escaping (TechUser)-> Void) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        
        databaseRef.child(safeEmail).observeSingleEvent(of: .value) { dataSnapshot in
            guard let value = dataSnapshot.value as? NSDictionary else {
                print("Fail to fetch data")
                return
            }
            let firstName = value["first_name"] as! String
            let lastName = value["last_name"] as! String
            let jobTitle = value["job_title"] as! String
            let bio = value["user_bio"] as! String
            let linkedinLink = value["linkedin_link"] as! String
            let githubLink = value["github_link"] as! String
            print(firstName)
            let t = TechUser(firstName: firstName, lastName: lastName, email: email, jobTitle: jobTitle, bio: bio, linkedinLink: linkedinLink, gitHubLinked: githubLink)
            completion(t)
        }
    }
    
    
    static func insertToAllUsers(with userCollection: [[String:String]]){
        databaseRef.child("users").setValue(userCollection) {
            (error:Error?, _ ) in
            if let error = error {
              print("Data in could not be save in all users: \(error).")
            } else {
              print("Data saveed successfully in all users!")
            }
        }
    }
    
    static func insertTechUser(with user: TechUser){
        databaseRef.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be save: \(error).")
            } else {
              print("Data save successfully!")
            }
        }
        
        databaseRef.child("users").observeSingleEvent(of: .value) { dataSnapshot in
            if var userCollection = dataSnapshot.value as? [[String:String]] {
                //append to the dic
                let newElement = [
                    "name" : user.firstName + " " + user.lastName,
                    "email" : user.safeEmail
                ]
                userCollection.append(newElement)
                self.insertToAllUsers(with: userCollection)
                
            }else {
                //create a new one
                let newCollection: [[String:String]] = [[
                    "name" : user.firstName + " " + user.lastName,
                    "email" : user.safeEmail
                ]]
                
                self.insertToAllUsers(with: newCollection)
            }
        }
  }
    
    static func updateTechUser(with user:TechUser , completion: @escaping (Bool) -> Void){
        
        databaseRef.child(user.safeEmail).updateChildValues([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "job_title": user.jobTitle!,
            "user_bio": user.bio!,
            "linkedin_link": user.linkedinLink ?? "" ,
            "github_link": user.gitHubLinked ?? ""
        ]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be update: \(error).")
                completion(false)
                
            } else {
              print("Data updated  successfully!")
                completion(true)
            }
        }
    }
    
}
// MARK: - Sending messages / conversations

extension FirebaseDatabaseClass {
    
    /// Create a new conversation with target user and fisrt message sent
    static func createNewConversation(with otherUserEmail:String, name:String ,firstMessage:Message, completion: @escaping (Bool)-> Void ){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        var safeEmail = currentEmail.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        
        databaseRef.child("\(safeEmail)").observeSingleEvent(of: .value) { dataSnapshot in
            guard var userNode = dataSnapshot.value as? [String: Any] else {
                completion(false)
                print("user not found in FBD createNewConversation ")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dataFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
              message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String:Any] = [
                "id" : conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array does exixt , append to  it
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                databaseRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    finishCreatingConversation(name:name,conversationId: conversationId, firstMessage:firstMessage, completion: completion)
                   // completion(true)
                }
            }else {
                //conversation array does not exixt , create it
                userNode["conversations"] = [newConversationData ]
                databaseRef.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    finishCreatingConversation(name:name, conversationId: conversationId, firstMessage:firstMessage, completion: completion)
                    //completion(true)
                }
            }
        }
        
    }

    
    static func finishCreatingConversation(name:String, conversationId:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dataFormatter.string(from: messageDate)
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
          message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        var currentUserEmailSafe = currentUserEmail.replacingOccurrences(of: ".", with: "-")
        currentUserEmailSafe =  currentUserEmailSafe.replacingOccurrences(of: "@", with: "-")
        
        let collectionMessage: [String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.msgKindString,
            "content": message,
            "date": dateString,
            "sender_email":currentUserEmailSafe,
            "is_read": false,
            "name": name
        ]
        let value:[String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        databaseRef.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    /// Fetched and returns all conversations for the user with passed email in
    static func getAllConversation(for email:String, completion: @escaping (Result<[Conversation],Error>) -> Void ){
        databaseRef.child("\(email)/conversations").observe(.value) { dataSnapshot in
            guard let value = dataSnapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.faildToFetch))
                return
            }
            let conversations:[Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool
                      else {
                    return nil
                }
                
                let latestMessageObj = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
            }
            completion(.success(conversations))
        }
    }
    
    //// Get all messages for given conversation
    static func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void ) {
        
    }
    
    /// Sends a message with target conversation and messagee
    static func sendMessage(to conversation: String, message:Message, completion: @escaping (Bool) -> Void){
        
    }
    
}


