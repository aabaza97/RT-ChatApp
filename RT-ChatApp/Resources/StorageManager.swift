//
//  StorageManager.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/12/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadCompletionHandler = (Result<String, Error>) -> Void
    public typealias downloadCompletionHandler = (Result<URL, Error>) -> Void
    
    public enum StorageErrors: Error {
        case FailedToUpload
        case FailedToDownload
    }
    
    ///Uploads images to a Firebase Storage specified location.
    public func uploadImage(with data: Data, to directory: String = "images", fileName: String, completion: @escaping uploadCompletionHandler) {
        
        let dirRef = storage.child("\(directory)/\(fileName)")
        
        dirRef.putData(data, metadata: nil) { (metaData, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.FailedToUpload))
                return
            }
            
            dirRef.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.FailedToDownload))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    public func downloadURL(for path: String,  completion: @escaping downloadCompletionHandler) {
        let dirRef = storage.child(path)
        dirRef.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.FailedToDownload))
                return
            }
            
            completion(.success(url))
        }
    }
}
