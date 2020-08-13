//
//  DBManager.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/9/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DbManager {
    
    //MARK: Properties
    static let shared = DbManager()
    private let db = Firestore.firestore()
    
}


//MARK: -User Manager
extension DbManager {
    
    ///Checks if a user is previously registered with email address
    func doesUserExist(with email: String, completion: @escaping ((Bool) -> Void)) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            guard let _ = snapshot else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///Inserts new user to database. CompletionHandler returns true on success & false on failure.
    public func createUser(from user: User, completion: @escaping (Bool) -> Void){
        let docRef = db.collection("users").document(user.userId)
        do {
            try docRef.setData(from: user, completion: { error in
                guard error == nil else {
                    print("failed to create user")
                    completion(false)
                    return
                }
                
                completion(true)
            })
        } catch let err {
            print(err)
        }
    }
}


//MARK: -Conversations Manager
extension DbManager {
    
}

