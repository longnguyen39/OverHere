//
//  UserService.swift
//  OverHere
//
//  Created by Long Nguyen on 9/21/21.
//

import UIKit
import Firebase

struct UserService {
    
    static func createNewUser(phone: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        let dataDefault = [
            "phoneNumber": phone,
            "username": "username...",
            "profileImageUrl": "none"
        ]
        
        Firestore.firestore().collection("users").document(phone).setData(dataDefault) { error in

            if let e = error?.localizedDescription {
                print("DEBUG-UserService: error registering \(e)")
                completion(.failure(e as! Error))
                return
            }

            print("DEBUG-UserService: successfully creating user \(phone)")
            completion(.success(phone))
        }
    }
    
    
    static func fetchUsers(phoneFull: String, completion: @escaping(Bool) -> Void) {
        let query = Firestore.firestore().collection("users")
        var newUserOrNot = true //assume that new user sign in
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("DEBUG-UserService: nothing here")
                return
            }
            print("DEBUG-UserService: we have \(documents.count) users")
            
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let userArray = documents.map({
                User(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-UserService: we now have big array of all users")
            
            //let's check to see if user exists ("user" collection must contain some users)
            if userArray.count == 0 {
                print("DEBUG-UserService: no user in database")
                return
            }
//can use either way
//-----------------------------------------------------------------------------------
//            for idx in 0...userArray.count-1 {
//                if phoneFull == userArray[idx].phone {
//                    newUserOrNot = false //no need new user
//                }
//            }
            for idx in userArray {
                if phoneFull == idx.phone {
                    newUserOrNot = false //no need new user
                }
            }
//-----------------------------------------------------------------------------------
            
            print("DEBUG-UserService: newUserOrNot is \(newUserOrNot)")
            completion(newUserOrNot)
        }
    }
    
    
    static func fetchUserInfo(phoneFull: String, completion: @escaping(User) -> Void) {
        let query = Firestore.firestore().collection("users").document(phoneFull)
        
        query.getDocument { snapshot, error in
            if let e = error?.localizedDescription {
                print("DEBUG-UserService: \(e)")
                return
            }
            guard let documents = snapshot?.data() else {
                print("DEBUG-UserService: something wrong..")
                return
            }
            let userInfo = User(dictionary: documents)
            completion(userInfo)
        }
        
    }
    
    
    static func updateUsername(phoneFull: String, newUsername: String, completion: @escaping(Result<String, Error>) -> Void) {
        let data = ["username": newUsername] as [String: Any]
        
        Firestore.firestore().collection("users").document(phoneFull).updateData(data) { error in
            
            if let e = error {
                print("DEBUG-UserService: error update username -  \(e.localizedDescription)")
                completion(.failure(e))
                return
            }
            print("DEBUG-UserService: successfully updating username")
            completion(.success(newUsername))
        }
        
    }
    
    
}

