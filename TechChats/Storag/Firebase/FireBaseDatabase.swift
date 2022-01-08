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
    
    static func insertTechUser(with user: TechUser){
        databaseRef.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be save: \(error).")
            } else {
              print("Data save  successfully!")
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
