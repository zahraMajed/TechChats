//
//  FireBaseAuth.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import Foundation
import FirebaseAuth

class FirebaseAuthClass {
    
    static func signUserIn(email: String, password:String, completion: @escaping (Bool) -> Void){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard let _ = authDataResult, error == nil else {
                print("Faild to sigin with email")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    static func signUserUp(firstName:String, lastName:String ,email: String, password:String, completion: @escaping (_ isExist: Bool?, _ isSignedUp:Bool?) -> Void){
        FirebaseDatabaseClass.checkExistenceOfUser(with: email) { isExist in
            if isExist {
                //to show an alert
                completion(true,false)
                return
            } else if !isExist {
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                    guard  authDataResult != nil , error == nil else {
                        print("Faild to create a user")
                        //show alert field to create a user may be some entry wrong ( if !isExist, !isSignedUp)
                        completion(false, false)
                        return
                    }
                    
                    FirebaseDatabaseClass.insertTechUser(with: TechUser(firstName: firstName, lastName: lastName, email: email))
                    //move to profile vc
                    completion(false, true)
                }
            }
        }
    }
    
    static func signUserOut(completion: @escaping (_ isSignedOut: Bool) -> Void){
        do {
            try FirebaseAuth.Auth.auth().signOut()
            completion(true)
        }catch {
            print("Faild to siginOut")
            completion(false)
        }
        
    }
}
