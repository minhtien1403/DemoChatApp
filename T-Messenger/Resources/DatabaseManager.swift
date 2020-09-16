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
            guard (datasnapshot.value as? String) != nil else{
                completion(false)
                return
            }
        })
        completion(true)
    }
    
    /// insert new user to database
    public func insertUser(user: AppUser){
        database.child(user.safeEmail).setValue([
            "first_name":user.firstname,
            "last_name":user.lastname
        ])
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
//    let avatar:String
}
