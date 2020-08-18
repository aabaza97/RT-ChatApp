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
    
    
    public enum DBManagerErrors: Error{
        //Users Errors
        case FailedToFetchUsers
        case NoUserWithProvidedId
        
        //Message Errros
        case FailedToSendMessage
        case FailedToFetchMessage
        case FailedToFetchConversations
        case FailedToCreateConversation
        case FailedToUpdate
        case NoConversations
        case NoMessages
    }
    
    
    public func getProfilePictureFileName(from email: String) -> String {
        return "profile_pirctures/\(email).png"
    }
}


//MARK: -User Manager
extension DbManager {
    
    public typealias fetchUsersCompletionHandler = (Result<[User], Error>) -> Void
    
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
    
    ///Completion: Array of User Objects
    public func fetchAllUsers(completion: @escaping fetchUsersCompletionHandler) {
        let colRef = db.collection("users")
        colRef.getDocuments { (snapshot, error) in
            guard let docs = snapshot?.documents, error == nil else {
                completion(.failure(DBManagerErrors.FailedToFetchUsers))
                return
            }
            
            var users = [User]()
            
            for doc in docs {
                let data = doc.data()
                let user = User(userId: data["userId"] as! String, username: data["username"] as! String, email: data["email"] as! String)
                users.append(user)
            }
            
            completion(.success(users))
        }
    }
    
    public func getUser(from userId: String, completion: @escaping (Result<User, Error>) -> Void ) -> Void {
  
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { (snapshot, error) in
            guard let doc = snapshot, error == nil, let userData = doc.data() else {
                completion(.failure(DBManagerErrors.NoUserWithProvidedId))
                return
            }
            
            let user = User(userId: userId, username: userData["username"] as! String, email: userData["email"] as! String)
            
            completion(.success(user))
        }
    }
}






//MARK: -Conversations Manager
extension DbManager {
    
    public typealias createConversationHandler = (Result<Conversation, Error>) -> Void
    public typealias messageSendingHandler = (Result<DocumentReference, Error>) -> Void
    public typealias fetchConversationsHandler = (Result<[Conversation], Error>) -> Void
    public typealias fetchMessagesHandler = (Result<[CMessage], Error>) -> Void
    public typealias conversationCheckerHandler = (Result<[String: Any], Error>) -> Void
    public typealias updateHandler = (Bool) -> Void
    
    ///creates new conversation between 2 users
    func createNewConversation(between users: [User], with message: CMessage, completion: @escaping createConversationHandler) -> Void {
        
        /*
         1- create new conversation
         2- create new message with the conversation Id
         3- update latest message in conversation with messageRef
         **/
        
        let docRef = db.collection("conversations").document()
        let ids = "\(users[0].userId)_\(users[1].userId)"
        let reverseIds = "\(users[1].userId)_\(users[0].userId)"
        let usersIds = [users[1].userId, users[0].userId]
        let conversation = Conversation(id: docRef.documentID, users: usersIds, idsCombination: [ids, reverseIds], usersData: users, messageContent: message.getMessageContent())
        
        do {
            try docRef.setData(from: conversation) { [weak self](error) in
                guard error == nil else {
                    completion(.failure(DBManagerErrors.FailedToCreateConversation))
                    return
                }
                
                message.setConversationId(from: docRef.documentID)
                
                self?.sendMessage(from: message) { (result) in
                    switch result {
                    case .success(_):
                        completion(.success(conversation))
                        break
                    case .failure(_):
                        completion(.failure(DBManagerErrors.FailedToCreateConversation))
                        break
                    }
                }
            }
        } catch _ {
            completion(.failure(DBManagerErrors.FailedToCreateConversation))
        }
    }
    
    
    ///Sends a new message in a conversation between 2 people from a CMessage Object
    func sendMessage(from message: CMessage, completion: @escaping messageSendingHandler) -> Void {
        let docRef = db.collection("messages").document()
        message.setMessageId(from: docRef.documentID)
        
        do {
            try docRef.setData(from: message, completion: { [weak self] error in
                guard error == nil else {
                    completion(.failure(DBManagerErrors.FailedToSendMessage))
                    return
                }
                self?.updateLatestMessage(in: message.getConversationId(), with: docRef, messageContent: message.getMessageContent(), completion: { (updated) in
                    if updated {
                        completion(.success(docRef))
                    } else {
                        completion(.failure(DBManagerErrors.FailedToUpdate))
                    }
                })
                
                completion(.success(docRef))
            })
        } catch _ {
            completion(.failure(DBManagerErrors.FailedToSendMessage))
        }
    }
    
    
    ///fetches all conversations of a user
    func fetchConversations(for user: User, completion: @escaping fetchConversationsHandler) -> Void {
        let colRef = db.collection("conversations")
        colRef.whereField("betweenUsers", arrayContains: user.userId).addSnapshotListener { (snapshot, error) in
            guard let docs = snapshot?.documents else {
                completion(.failure(DBManagerErrors.FailedToFetchConversations))
                return
            }
            var conversations = [Conversation]()
            for doc in docs {
                var usersData: [User] = [User]()
                let data = doc.data()
                let conversationUsers = data["usersData"] as! [[String: Any]]
                for userObject in conversationUsers {
                    let user = User(userId: userObject["userId"] as! String, username: userObject["username"] as! String, email: userObject["email"] as! String)
                    usersData.append(user)
                }
                let conversation = Conversation(id: data["conversationId"] as! String,
                                                users: data["betweenUsers"] as! [String],
                                                message: data["latestMessageRef"] as! DocumentReference,
                                                idsCombination: data["combinedUsers"] as! [String],
                                                usersData: usersData,
                                                messageContent: data["latestMessageContent"] as! String)
                conversations.append(conversation)
            }
            
            completion(.success(conversations))
        }
    }
    
    
    ///fetches all messages of a conversation using its ID
    func fetchConversationMessages(for conversation: String, completion: @escaping fetchMessagesHandler) -> Void {
        let colRef = db.collection("messages")
        colRef.whereField("conversationId", isEqualTo: conversation)
            .order(by: "date", descending: false).getDocuments { (snapshot, error) in
                guard let docs = snapshot?.documents else {
                    completion(.failure(DBManagerErrors.FailedToFetchMessage))
                    return
                }
                var messages = [CMessage]()
                for doc in docs {
                    let data = doc.data()
                    let message = CMessage(id: data["messageId"] as! String,
                                           conversationId: data["conversationId"] as! String,
                                           senderId : data["senderId"] as! String,
                                           receiverId: data["receiverId"] as! String,
                                           date: data["date"] as! Date,
                                           isRead: data["isRead"] as! Bool,
                                           type: data["type"] as! String,
                                           content: data["content"] as! String)
                    messages.append(message)
                }
                
            completion(.success(messages))
        }
        
    }
    
    
    ///checks if conversation exists between two users
    func doesConversationExist(between users: [User], completion: @escaping conversationCheckerHandler) -> Void {
        let colRef = db.collection("conversations")
        let ids = "\(users[0].userId)_\(users[1].userId)"
        let reversedIds = "\(users[1].userId)_\(users[0].userId)"
        colRef.whereField("combinedUsers", arrayContainsAny: [ids, reversedIds])
            .getDocuments { (snapshot, error) in
                guard let snap = snapshot else {
                    completion(.failure(DBManagerErrors.NoConversations))
                    return
                }
                if snap.count > 0 {
                    let result = (snap.documents)[0].data()
                    completion(.success(result))
                } else {
                    completion(.failure(DBManagerErrors.NoConversations))
                }
        }
    }
    
    
    ///Updates Latest message in a conversation
    func updateLatestMessage(in conversation: String, with messageRef: DocumentReference, messageContent: String, completion: @escaping updateHandler) -> Void {
        let docRef = db.collection("conversations").document(conversation)
        docRef.updateData(["latestMessageRef" : messageRef,
                           "latestMessageContent" : messageContent]) { (error) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    ///Fetches latest Messages Ids
    func fetchLatestMessage(for conversation: String, compltion: @escaping messageSendingHandler) -> Void {
        
    }
    
    
    func readMessage(for message: DocumentReference, completion: @escaping updateHandler) -> Void {
        message.updateData(["isRead" : true]) { (error) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
}

