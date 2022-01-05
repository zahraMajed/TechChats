//
//  FireBaseDatabase.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import Foundation
import FirebaseDatabase

class FirebaseDatabaseClass {
    
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
    
    static func insertTechUser(with user: TechUser){
        databaseRef.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }
    
    //update
  
}
