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
    
    public typealias uploadImageCompletion = (Result<String, Error>) -> Void
    
    public enum StroageErrors: Error {
        case FailedToUpload
        case FailedToDownload
    }
    
    ///Uploads images to a Firebase Storage specified location.
    public func uploadImage(with data: Data, to directory: String = "images", fileName: String, completion: @escaping uploadImageCompletion) {
        
        let dirRef = storage.child("\(directory)/\(fileName)")
        
        dirRef.putData(data, metadata: nil) { (metaData, error) in
            guard error == nil else {
                completion(.failure(StroageErrors.FailedToUpload))
                return
            }
            
            dirRef.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StroageErrors.FailedToDownload))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
}
