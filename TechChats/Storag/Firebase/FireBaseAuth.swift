//
//  FireBaseAuth.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import Foundation
import FirebaseAuth

class FirebaseAuthClass {
    
    
    /// sign user in 
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
    
    /// sign user up if user does not have an acount
    static func signUserUp(firstName:String, lastName:String ,email: String, password:String, completion: @escaping (_ isExist: Bool, _ isSignedUp:Bool, _ errorInfo:String?) -> Void){
        FirebaseDatabaseClass.checkExistenceOfUser(with: email) { isExist in
            if isExist {
                //to show an alert
                completion(true,false,nil)
                return
            } else if !isExist {
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                    guard  authDataResult != nil , error == nil else {
                        print("Faild to create a user")
        
                        let errorA = error! as NSError
                        let errorAInfo = errorA.userInfo as Dictionary?
                        let errorInfo = errorAInfo![1].value as! String
                        print(errorInfo)
                        //show alert field to create a user may be some entry wrong ( if !isExist, !isSignedUp)
                        completion(false, false, errorInfo)
                        return
                    }
                    
                    FirebaseDatabaseClass.insertTechUser(with: TechUser(firstName: firstName, lastName: lastName, email: email))
                    //move to profile vc
                    completion(false, true,nil)
                }
            }
        }
    }
    
    /// shign user out
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
