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
    
    ///Checks if user registered with email address
    func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            guard let _ = snapshot else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Inserts new user to database
    public func createUser(from user: User){
        let docRef = db.collection("users").document()
        do {
            try docRef.setData(from: user)
        } catch let err {
            print(err)
        }
    }
}


//MARK: -Conversations Manager
extension DbManager {
    
}

struct User: Codable {
    let username: String
    let email: String
   
}
