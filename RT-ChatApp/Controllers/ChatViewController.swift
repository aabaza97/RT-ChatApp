//
//  ChatViewController.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/8/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import UIKit
import MessageKit

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
        
    }
}



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
