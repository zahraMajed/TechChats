//
//  TechUserStruct.swift
//  TechChats
//
//  Created by administrator on 05/01/2022.
//

import Foundation

struct TechUser {
    let firstName:String
    let lastName:String
    let email:String
    var safeEmail:String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    //optins 
    //let image
    //let jobTitle
    //let bio
    //let soccialMediaLinks: dict
}
