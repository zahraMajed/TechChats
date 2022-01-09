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
    
    static func getTechUserObj(with email:String) -> TechUser {
        var firstName = ""; var lastName = ""; var jobTitle = "";
        var bio = ""; var linkedinLink = ""; var githubLink = "";
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        
        databaseRef.child(safeEmail).observeSingleEvent(of: .value) { dataSnapshot in
            guard let value = dataSnapshot.value as? NSDictionary else {
                print("Fail to fetch data")
                return
            }
            firstName = value["first_name"] as! String
            lastName = value["last_name"] as! String
            jobTitle = value["job_title"] as! String
            bio = value["user_bio"] as! String
            linkedinLink = value["linkedin_link"] as! String
            githubLink = value["github_link"] as! String
            print(firstName)
        }
        
        return TechUser(firstName: firstName, lastName: lastName, email: email, jobTitle: jobTitle, bio: bio, linkedinLink: linkedinLink, gitHubLinked: githubLink)
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
                    "eamil" : user.safeEmail
                ]
                userCollection.append(newElement)
                self.insertToAllUsers(with: userCollection)
                
            }else {
                //create a new one
                let newCollection: [[String:String]] = [[
                    "name" : user.firstName + " " + user.lastName,
                    "eamil" : user.safeEmail
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
