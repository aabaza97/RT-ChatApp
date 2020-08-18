//
//  Conversation.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/16/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Conversation: Codable {
    var conversationId: String
    let betweenUsers: [String] // users Ids
    let combinedUsers: [String] // combined users Ids
    let usersData: [User]
    let latestMessageRef: DocumentReference?
    let latestMessageContent: String
    
    init(id: String, users: [String], message: DocumentReference, idsCombination: [String], usersData: [User], messageContent: String) {
        self.conversationId = id
        self.betweenUsers = users
        self.latestMessageRef = message
        self.combinedUsers = idsCombination
        self.usersData = usersData
        self.latestMessageContent = messageContent
    }
    
    init(id: String, users: [String], idsCombination: [String], usersData: [User], messageContent: String) {
        self.conversationId = id
        self.betweenUsers = users
        self.latestMessageRef = nil
        self.combinedUsers = idsCombination
        self.usersData = usersData
        self.latestMessageContent = messageContent
    }
}



class CMessage: Codable {
    private var messageId: String
    private var conversationId: String
    private let senderId: String
    private let receiverId: String
    private let date: Date
    private let isRead: Bool
    private let type: String
    private let messageContent: String // if text stores the text, if others stores the url
    
    init(id: String, conversationId: String, senderId: String, receiverId: String, date: Date, isRead: Bool = false, type: String, content: String) {
        self.messageId = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.receiverId = receiverId
        self.date = date
        self.isRead = isRead
        self.type = type
        self.messageContent = content
    }
    
    func setConversationId(from: String) -> Void {
        self.conversationId = from
    }
    
    func setMessageId(from: String) -> Void {
        self.messageId = from
    }
    
    func getMessageId() -> String {
        return self.messageId
    }
    
    func getConversationId() -> String {
        return self.conversationId
    }
    
    func getMessageContent() -> String{
        return self.messageContent
    }
}
