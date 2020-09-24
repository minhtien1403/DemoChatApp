//
//  ChatViewController.swift
//  T-Messenger
//
//  Created by Tiến on 9/22/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    private var message = [Message]()
    
    private let sendMess = Sender(senderId: "1",
                                     displayName: "Tien",
                                     avatarURL: "")
    private let receiveMess = Sender(senderId: "2",
                                     displayName: "Trang",
                                     avatarURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        message.append(Message(sender: sendMess,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("Hello there")))
        message.append(Message(sender: receiveMess,
                               messageId: "2",
                               sentDate: Date(),
                               kind: .text("Nice to meet you")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        return sendMess
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var avatarURL: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
