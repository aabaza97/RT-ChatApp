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
    let betweenUsers: [String]
    let combinedUsers: [String]
    let latestMessage: DocumentReference?
    
    init(id: String, users: [String], message: DocumentReference, idsCombination: [String]) {
        self.conversationId = id
        self.betweenUsers = users
        self.latestMessage = message
        self.combinedUsers = idsCombination
    }
    
    init(id: String, users: [String], idsCombination: [String]) {
        self.conversationId = id
        self.betweenUsers = users
        self.latestMessage = nil
        self.combinedUsers = idsCombination
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
    private let messageContent: String
    
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
        return messageId
    }
}
