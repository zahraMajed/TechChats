//
//  FirebaseStoarge.swift
//  TechChats
//
//  Created by administrator on 06/01/2022.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageClass {
    
    static let storageRef = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    static func uploadProfilePicture(with data:Data, fileName:String, completion: @escaping UploadPictureCompletion){
        storageRef.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(.failure(StoargeErrors.FaildToUplaod))
                return
            }
            
            storageRef.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StoargeErrors.FaildToDownload))
                    return
                }
                completion(.success(url.absoluteString))
            }
        }
    }
    
    public enum StoargeErrors:Error {
        case FaildToUplaod
        case FaildToDownload
    }
    
    static func downloadURL(for path:String, completion: @escaping (Result<URL,Error>)-> Void){
        storageRef.child(path).downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StoargeErrors.FaildToDownload))
                return
            }
            completion(.success(url))
        }
    }
    
}
