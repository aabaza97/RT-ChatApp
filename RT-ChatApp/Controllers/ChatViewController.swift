//
//  ChatViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/8/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}



class ChatViewController: MessagesViewController {

    //MARK: -Interface Elements
    
    
    
    //MARK: -Properties
    private var messages = [Message]()
    private let selfSender = Sender(senderId: "1", displayName: "Ahmed")
    
    public var appUser: User!
    public var otherUser: User!
    public var isNewConversation: Bool!
    public var conversation: Conversation? = nil
    
    
    //MARK: -Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello Dear")))
        
    }
    
    
    
    //MARK: -Functions
    private func configureViewController() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        self.title = otherUser.username
    }
    
    private func loadMessages() {
        guard let conversation = self.conversation else {
            return
        }
        
        DbManager.shared.fetchConversationMessages(for: conversation.conversationId) { (result) in
            switch result {
            case.failure(_):
                break
            case.success(let messages):
                
                break
            }
        }
    }
}


//MARK: -Extensions
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}



extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let appUser = self.appUser, let otherUser = self.otherUser else {
            return
        }
        
        /*
         1- if new conversation -- create a new one
         2- if not new conversation --- append to a previous one
        */
        
        
        let message = CMessage(id: "", conversationId: "", senderId: appUser.userId, receiverId: otherUser.userId, date: Date(), type: "text", content: text)
        
        if isNewConversation {
            let conversationMembers = [appUser, otherUser]
            
            DbManager.shared.createNewConversation(between: conversationMembers, with: message) { (result) in
                switch result {
                case .failure(_):
                    print("failed to send Message")
                    break
                case .success(let msgRef):
                    print("Added: \(msgRef.documentID)")
                    break
                }
            }
            
        } else {
            // append to an existing conversation
        }
        
        
    }
}
