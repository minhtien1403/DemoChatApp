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



