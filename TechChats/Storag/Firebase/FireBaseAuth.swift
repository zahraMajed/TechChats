//
//  FireBaseAuth.swift
//  TechChats
//
//  Created by administrator on 04/01/2022.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthClass {
    
    
    /// sign user in 
    static func signUserIn(email: String, password:String, completion: @escaping (Bool) -> Void){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard let _ = authDataResult, error == nil else {
                print("Faild to sigin with email")
                completion(false)
                return
            }
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(getNameWith(email: email), forKey: "name")
            completion(true)
        }
    }
    
    /// sign user up if user does not have an acount
    static func signUserUp(firstName:String, lastName:String ,email: String, password:String, completion: @escaping (_ isExist: Bool, _ isSignedUp:Bool, _ errorInfo:String?, _ techUSerObj:TechUser?) -> Void) {
        FirebaseDatabaseClass.checkExistenceOfUser(with: email) { isExist in
            if isExist {
                //to show an alert
                completion(true,false,nil,nil)
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
                        completion(false, false, errorInfo,nil)
                        return
                    }
                    let techUserObj = TechUser(firstName: firstName, lastName: lastName, email: email)
                    FirebaseDatabaseClass.insertTechUser(with: techUserObj)
                    //move to profile vc
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue(getNameWith(email: email), forKey: "name")
                    completion(false, true,nil, techUserObj)
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
    
    static func getNameWith(email:String) -> String {
        var userName = ""
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        FirebaseDatabaseClass.getTechUserData(with: safeEmail) { isDataFetched, userDic in
            if isDataFetched {
                if let userDic = userDic {
                    userName = "\(userDic["first_name"] as! String ) \(userDic["last_name"] as! String)"
              }
            }
        }
        print("user name in getName Firebase Auth: ",userName)
        return userName
    }
}
