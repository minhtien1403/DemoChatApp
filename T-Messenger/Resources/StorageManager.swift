//
//  StorageManager.swift
//  T-Messenger
//
//  Created by Tiến on 9/24/20.
//  Copyright © 2020 Tiến. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    /// upload avatar picture to firebase storage and return completion with url String to download
    public func uploadAvatar(with data: Data, filename: String, completion: @escaping UploadPictureCompletion ){
        storage.child("images/\(filename)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                print("Failed to upload data to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self.storage.child("images/\(filename)").downloadURL { (URL, Error) in
                guard let url = URL else{
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url return: \(urlString)")
                completion(.success(urlString))
            }
            
        })
    }
    
    
    public enum StorageError: Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
}
