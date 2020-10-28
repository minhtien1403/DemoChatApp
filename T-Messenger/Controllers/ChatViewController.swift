//
//  ChatViewController.swift
//  T-Messenger
//
//  Created by Tiến on 9/22/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    public let receiverEmail : String
    private let conversationID: String?
    private var messages = [Message]()
    
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    init(with email: String, id: String?) {
        self.receiverEmail = email
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        if let ConversationID = conversationID{
            startListenforMessages(id: ConversationID)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // sender is the current user who is sending message
    private var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "user_email") as? String else {
            return nil
        }
        let convertedEmail = DatabaseManager.safemail(email: email)
        return Sender(senderId: convertedEmail, displayName: "Tien", avatarURL: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder()
        messagesCollectionView.scrollToBottom()
        if let ConversationID = conversationID{
            startListenforMessages(id: ConversationID)
        }
    }
    
    private func startListenforMessages(id: String){
        DatabaseManager.shared.getAllMessageInConversation(with: id) {[weak self] (Result) in
            switch(Result){
            case.success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            case.failure(let error):
                print("cant get messages because: \(error.localizedDescription)")
            }
            }
        }
    }


extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: "").isEmpty,
            let sender = self.sender,
            let messageID = creataMessageID() else {
                return
        }
        print("Sending: \(text)")
        //send message
        let message = Message(sender: sender,
        messageId: messageID,
        sentDate: Date(),
        kind: .text(text))
        if isNewConversation{
            //create new conversation in Database
            DatabaseManager.shared.createNewConversation(with: receiverEmail, name: self.title ?? "user", firstMessage: message) { [weak self] (success) in
                if success{
                    print("New Conversation Saved to UserNode in Database - ChatViewController")
                    self?.isNewConversation = false
                }
                else{
                    print("can create new conversation")
                }
                self?.startListenforMessages(id: "conversation_\(messageID)")
            }
        }
        else{
            //append message to existing conversation
            guard let conversationID = conversationID, let receiverName = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID, ReceiverName: receiverName, receiverEmail: receiverEmail, message: message, completion: { success in
                if success{
                    print("message sent")
                }
                else{
                    print("something wrong when sending message")
                }
            })
        }
        inputBar.inputTextView.text = ""
    }
    
    private func creataMessageID() -> String? {
        let date = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safemail(email: currentUserEmail)
        let id = "\(safeEmail)_\(receiverEmail)_\(date)"
        return id
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        return sender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
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

extension MessageKind{
    var kind: String{
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link"
        case .custom(_):
            return "custom"
        }
    }
}
