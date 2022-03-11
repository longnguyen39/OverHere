//
//  FetchingStuff.swift
//  OverHere
//
//  Created by Long Nguyen on 10/23/21.
//

import Foundation
import Firebase

struct FetchingStuff {
    
    static func fetchAllUsers(completion: @escaping([User]) -> Void) {
        let query = Firestore.firestore().collection("users")
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("DEBUG-FetchingStuff: nothing here")
                return
            }
            
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let userArray = documents.map({
                User(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-FetchingStuff: there are \(userArray.count) users")
            completion(userArray)
        }
    }
    
    static func fetchAllFriends(currentPh: String, completion: @escaping([User]) -> Void) {
        let query = Firestore.firestore().collection("users").document(currentPh).collection("friends").order(by: "timeLong", descending: true)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("DEBUG-FetchingStuff: no friends here")
                return
            }
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let friendsArray = documents.map({
                User(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-FetchingStuff: so \(friendsArray.count) friends")
            completion(friendsArray)
        }
    }
    
    //for this, we gotta fetch a certain amount of texts, we should NOT fetch all the texts at once when this func is called
    static func fetchMessages(currentUser: User, otherUser: User, completion: @escaping([Message]) -> Void) {
        
        var messagesFetched = [Message]()
        let currentPh = currentUser.phone
        let otherPh = otherUser.phone
        
        let query = Firestore.firestore().collection("users").document(currentPh).collection("friends").document(otherPh).collection("messages").order(by: "timeLong")
        
        //The addSnapshotListener keeps the conversation going by fetching your message instantly without refreshing your ChatController to see new message
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionaryChanged = change.document.data() //data() is given automatically
                    messagesFetched.append(Message(dictionary: dictionaryChanged))
                    completion(messagesFetched)
                }
            })
            print("DEBUG-FetchingStuff: here \(messagesFetched.count) texts")
        }
        
        
//2nd query (fetch a certain amount of texts, but needs more modification for paginition)
//        query.addSnapshotListener { (snapshot, error) in
//            guard let count = snapshot?.documents.count else { return }
//            guard let change = snapshot?.documentChanges else { return }
//            print("DEBUG-FetchingStuff: we have \(count) text")
//
//            //we only fetch 15 messages
//            for docs in 1...15 {
//                let idx = count - docs
//                if change[idx].type == .added {
//                    let dictionaryChanged = change[docs].document.data() //data() is given automatically
//                    messagesFetched.append(Message(dictionary: dictionaryChanged))
//                    completion(messagesFetched)
//                }
//            }
//
//            print("DEBUG-FetchingStuff: here \(messagesFetched.count) texts")
//        }
        
        
    }
    
    static func fetchConver(currentUser: User, completion: @escaping([Conversation]) -> Void) {
        let query = Firestore.firestore().collection("users").document(currentUser.phone).collection("friends").order(by: "timeLong", descending: true) //fetch reversely base on time
        var converFetch = [Conversation]()
        
        //use snapshotListener to listen for if new conver is added or deleted
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                let dictionaryChanged = change.document.data() //data() is given automatically
                converFetch.append(Conversation(dictionary: dictionaryChanged))
                completion(converFetch)
            })
            print("DEBUG-FetchingStuff: here \(converFetch.count) conver")
        }
        
    }
    
    static func fetchUpdateConver(currentPh: String, completion: @escaping([Conversation]) -> Void) {
        let query = Firestore.firestore().collection("users").document(currentPh).collection("friends").order(by: "timeLong", descending: true)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("DEBUG-FetchingStuff: no conv here")
                return
            }
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let converArr = documents.map({
                Conversation(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-FetchingStuff: so \(converArr.count) conv")
            completion(converArr)
        }
    }
    
    static func fetchStatus(firstUser: User, secondUser: User, completion: @escaping(Conversation) -> Void) {
        let query = Firestore.firestore().collection("users").document(firstUser.phone).collection("friends").document(secondUser.phone)
        
        query.getDocument { snapshot, error in
            if let e = error?.localizedDescription {
                print("DEBUG-FetchingStuff: \(e)")
                return
            }
            guard let documents = snapshot?.data() else {
                print("DEBUG-FetchingStuff: no shit..")
                return
            }
            let conver = Conversation(dictionary: documents)
            print("DEBUG-FetchingStuff: done fetch status")
            completion(conver)
        }
    }
    
    
    static func fetchPhotos(phone: String, completion: @escaping([Picture]) -> Void) {
        
        let query = Firestore.firestore().collection("users").document(phone).collection("library").order(by: "timestamp", descending: true) //fetch data base on chronological order, either true or false
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            print("DEBUG-FetchingStuff: we have \(documents.count) photos")
            
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let photoArray = documents.map({
                Picture(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-FetchingStuff: we now have big array of all photos")//show photoArray
            completion(photoArray)
        }
        
    }
    
    
}
