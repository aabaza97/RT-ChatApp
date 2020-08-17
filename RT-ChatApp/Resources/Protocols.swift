//
//  Protocols.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/16/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation

protocol ConversationDelegate {
    func newConversation(user: User) -> Void
    
}
