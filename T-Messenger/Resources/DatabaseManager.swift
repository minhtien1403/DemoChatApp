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
        database.child(user.safeEmail).setValue([
            "first_name":user.firstname,
            "last_name":user.lastname
            ],withCompletionBlock: {error,_ in
                guard error == nil else{
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                completion(true)
        })
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



