//
//  DatabaseManager.swift
//  T-Messenger
//
//  Created by Tiến on 9/15/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safemail(email: String) -> String{
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    public func isNewUser(with email:String,
                          completion: @escaping( (Bool) -> Void ) ){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { datasnapshot in
            completion(!datasnapshot.exists())
            return
        })
    }
    
    /// insert new user to database
    public func insertUser(user: AppUser, completion: @escaping (Bool) -> Void){
        
        database.child(user.safeEmail).setValue(
            [
                "first_name":user.firstname,
                "last_name":user.lastname
            ]
            ,withCompletionBlock: {error,_ in
                guard error == nil else{
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                // list all users
                self.database.child("users").observeSingleEvent(of: .value) { (DataSnapshot) in
                    if var userCollection = DataSnapshot.value as? [[String:String]]{
                        //append user array dictionary
                        let newElement = [
                                "name":user.lastname+" "+user.firstname,
                                "email":user.safeEmail
                        ]
                        userCollection.append(newElement)
                        self.database.child("users").setValue(userCollection, withCompletionBlock: { error,_ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                    else{
                        //create user array dictionary
                        let newCollection: [[String:String]] = [
                            [
                                "name":user.lastname+" "+user.firstname,
                                "email":user.safeEmail
                            ]
                        ]
                        self.database.child("users").setValue(newCollection, withCompletionBlock: { error,_ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                             completion(true)
                        })
                    }
                }
        })
    }
    
    public func getAllUser(completion: @escaping (Result<[[String:String]],Error>) -> Void ){
        database.child("users").observe(.value) { (DataSnapshot) in
            guard let value = DataSnapshot.value as? [[String:String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
        
    }
}

/// Mark: Sending message / Conversation
extension DatabaseManager{
    // create new converation with receiver user email and first message
    public func createNewConversation(with receiverEmail:String, name: String, firstMessage:Message, completion: @escaping (Bool) -> Void){
        guard let currentemail = UserDefaults.standard.value(forKey: "user_email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safemail(email: currentemail)
        
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value) { [weak self] (DataSnapshot) in
            guard var userNode = DataSnapshot.value as? [String:Any] else{
                completion(false)
                print("Cant found user")
                return
            }
            
            let messageDate = ChatViewController.dateFormatter.string(from: firstMessage.sentDate)
            var message = ""
            
            switch firstMessage.kind{
                
            case .text(let textMessagae):
                message = textMessagae
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id": conversationID,
                "receiver_email": receiverEmail,
                "name": name,
                "latest_message": [
                    "date": messageDate,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            guard let lastname = userNode["last_name"] as? String,
                let firstname = userNode["first_name"] as? String else{
                    print("Cant get my name")
                    return
            }
            
            let ReceivernewConversationData: [String:Any] = [
                "id": conversationID,
                "receiver_email": safeEmail,
                "name": lastname+" "+firstname,
                "latest_message": [
                    "date": messageDate,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                //if current user already have converstion array -> append new conversation to exist array
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] (Error, _) in
                    guard Error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreateConverastion(name: name,
                                                   conversationID: conversationID,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                }
                
            }
            else{
                // create new conversation array for this user
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { [weak self] (Error, _) in
                    guard Error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreateConverastion(name: name,
                                                   conversationID: conversationID,
                                                   firstMessage: firstMessage,
                                                   completion: completion)
                }
            }
            
            // update receiver user conversation entry
            self?.database.child("\(receiverEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] (DataSnapshot) in
                if var conversation = DataSnapshot.value as? [[String:Any]]{
                    //append
                    conversation.append(ReceivernewConversationData);
                    self?.database.child("\(receiverEmail)/conversations").setValue(conversation)
                }
                else{
                    //create
                    self?.database.child("\(receiverEmail)/conversations").setValue([ReceivernewConversationData])
                }
            })
            
        }
    }
    
    private func finishCreateConverastion(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void ){
        let messageDate = ChatViewController.dateFormatter.string(from: firstMessage.sentDate)
        var content = ""
        
        switch firstMessage.kind{
            
        case .text(let textMessagae):
            content = textMessagae
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard  let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else {
            completion(false)
            return
        }
        let safeEmail = DatabaseManager.safemail(email: currentUserEmail)
        
        let message: [String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.kind,
            "content": content,
            "date": messageDate,
            "sender_email": safeEmail,
            "is_read": false,
            "name": name // receiver name
        ]
        
        let value: [String:Any] = [
            "messages": [
                message
            ]
        ]
        database.child(conversationID).setValue(value) { (Error, _) in
            guard Error == nil else {
                completion(false)
                return
            }
            print("New ConversationNode saved to Database - Database Manager")
            completion(true)
        }
    }
    
    //Fetch and return all conversation for the user
    public func getAllConversation(for email:String, completion: @escaping (Result<[Conversations],Error>) -> Void){
        
        database.child("\(email)/conversations").observe(.value) { (DataSnapshot) in
            guard let value = DataSnapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("start mapping conversation ....")
          
            let conversations: [Conversations] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let receiverEmail = dictionary["receiver_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String:Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else{
                        print("somthing wrong at here...")
                        return nil
                }
                let lastestMessageObject = LatestMessage(date: date, message: message, isRead: isRead)
                return Conversations(id: conversationID, name: name, receiverEmail: receiverEmail, latestMessage: lastestMessageObject)
            })
           
            completion(.success(conversations))
        }
    }
    
    public func getAllMessageInConversation(with id:String, completion: @escaping (Result<[Message],Error>) -> Void){
        database.child("\(id)/messages").observe(.value) { (DataSnapshot) in
            guard let value = DataSnapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ Dictionary in
                guard let name = Dictionary["name"] as? String,
                    //let isRead = Dictionary["is_read"] as? String,
                    let messageID = Dictionary["id"] as? String,
                    let content = Dictionary["content"] as? String,
                    let dateString = Dictionary["date"] as? String,
                    let senderEmail = Dictionary["sender_email"] as? String,
                    //let type = Dictionary["type"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                let sender = Sender(senderId: senderEmail, displayName: name, avatarURL: "")
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
            })
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversationID:String, ReceiverName: String, receiverEmail:String, message: Message, completion: @escaping (Bool) -> Void){
        
        // add new message to messages in conversationID
        database.child("\(conversationID)/messages").observeSingleEvent(of: .value) { [weak self] (DataSnapshot) in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = DataSnapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            let messageDate = ChatViewController.dateFormatter.string(from: message.sentDate)
            var content = ""
            
            switch message.kind{
                
            case .text(let textMessagae):
                content = textMessagae
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard  let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else {
                completion(false)
                return
            }
            let safeEmail = DatabaseManager.safemail(email: currentUserEmail)
            
            let newMessage: [String:Any] = [
                "id": message.messageId,
                "type": message.kind.kind,
                "content": content,
                "date": messageDate,
                "sender_email": safeEmail,
                "is_read": false,
                "name": ReceiverName // receiver name
            ]
            
            currentMessages.append(newMessage)
            strongSelf.database.child("\(conversationID)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else{
                    completion(false)
                    return
                }
                //append new message success -> update sender latest message
                strongSelf.database.child("\(safeEmail)/conversations").observeSingleEvent(of: .value) { (DataSnapshot) in
                    guard var currentConversation = DataSnapshot.value as? [[String:Any]] else{
                        completion(false)
                        return
                    }
                    let updateValue:[String:Any] = [
                        "date": messageDate,
                        "message": content,
                        "is_read": false
                    ]
                    var targetConversation:[String:Any]?
                    var position = 0
                    for convesation in currentConversation {
                        if let id = convesation["id"] as? String, id == conversationID{
                            targetConversation = convesation
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updateValue
                    guard let final = targetConversation else{
                        completion(false)
                        return
                    }
                    currentConversation[position] = final
                    strongSelf.database.child("\(safeEmail)/conversations").setValue(currentConversation) { (error, _) in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        //update sender latest message success -> update receiver latest message
                        strongSelf.database.child("\(receiverEmail)/conversations").observeSingleEvent(of: .value) { (DataSnapshot) in
                            guard var receiverConversation = DataSnapshot.value as? [[String:Any]] else {
                                completion(false)
                                return
                            }
                            let updateValue:[String:Any] = [
                                "date": messageDate,
                                "message": content,
                                "is_read": false
                            ]
                            var targetConversation:[String:Any]?
                            var position = 0
                            for convesation in receiverConversation {
                                if let id = convesation["id"] as? String, id == conversationID{
                                    targetConversation = convesation
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updateValue
                            guard let final = targetConversation else{
                                completion(false)
                                return
                            }
                            receiverConversation[position] = final
                            strongSelf.database.child("\(receiverEmail)/conversations").setValue(receiverConversation) { (error, _) in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
                
               
            }
        }
        
    }
}

struct AppUser {
    let email:String
    let firstname:String
    let lastname:String
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    var avatarFileName: String{
        return "\(safeEmail)_avatar_picture.png"
    }
}



