//
//  TechUserStruct.swift
//  TechChats
//
//  Created by administrator on 05/01/2022.
//

import Foundation

struct TechUser {
    var firstName:String
    var lastName:String
    let email:String
    var safeEmail:String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail =  safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName:String {
        return "\(safeEmail)_profile_picture.png"
    }
    var jobTitle:String?
    var bio:String?
    var linkedinLink:String?
    var gitHubLinked:String?
    
    //optins 
    //let image
   
}
