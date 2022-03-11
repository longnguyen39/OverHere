//
//  UploadInfo.swift
//  OverHere
//
//  Created by Long Nguyen on 10/20/21.
//

import UIKit
import Firebase

struct UploadInfo {
    
//MARK: - Upload images
    
    //the completion block will return a string, which is the url for the image
    static func uploadProfileImage(image: UIImage, phone: String, completionBlock: @escaping(String) -> Void) {
        
        //let's make the compressionQuality little smaller so that it's faster when we download the file image from the internet
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("DEBUG: error setting imageData")
            return
        }
        let ref = Storage.storage().reference(withPath: "/profile_images/\(phone)")
        
        //let's put the image into the database in Storage
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("DEBUG-UploadInfo: error putData - \(String(describing: error?.localizedDescription))")
                return
            }
            //let download the image that we just upload to storage
            ref.downloadURL { (url, error) in
                
                guard let imageUrl = url?.absoluteString else { return }
                completionBlock(imageUrl) //whenever this uploadImage func gets called (with an image already uploaded), we can use the downloaded url as imageUrl
                print("DEBUG-UploadInfo: upload profileImageUrl is \(imageUrl)")
            }
        } //done putting image into storage
    }
    
    static func uploadLibraryImage(image: UIImage, phone: String, title: String, timestamp: String, completionBlock: @escaping(String) -> Void) {
        
        //let's make the compressionQuality smaller so  it's faster when we download
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("DEBUG-UploadInfo: fail to set imageData")
            return
        }
        
        let ref = Storage.storage().reference(withPath: "/library/\(phone)/\(title)-\(timestamp)")
        
        //let's put the image into the database in Storage
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error putData - \(e)")
                return
            }
            //let download the image that we just upload to storage
            ref.downloadURL { (url, error) in
                guard let imageUrl = url?.absoluteString else { return }
                completionBlock(imageUrl) //convert the img into url
                print("DEBUG-UploadInfo: successfully upload image to storage with url \(imageUrl)")
            }
        } //done putting image into storage
         
    }
    
    
    static func uploadLocationAndPhoto(userPhone: String, takenImage: UIImage, photoInfo: Picture, dictionary: [String: Any], text: String, completionBlock: @escaping(Error?) -> Void) {

        let timeLong = photoInfo.timestamp
        var imgUrl = "no url"
        
        //upload to info database
        Firestore.firestore().collection("users").document(userPhone).collection("library").document(timeLong).setData(dictionary) { error in
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error uploading info - \(e)")
                return
            }
            print("DEBUG-UploadInfo: done uploading info photo")
        }
        
        //now upload the img to Storage and update the imageURL in Firestore
        uploadLibraryImage(image: takenImage, phone: userPhone, title: text, timestamp: timeLong) { imageUrl in
            
            imgUrl = imageUrl
            let data = ["imageURL": imgUrl] as [String: Any]
            
            Firestore.firestore().collection("users").document(userPhone).collection("library").document(timeLong).updateData(data, completion: completionBlock)
        }

    }
    
//MARK: - Upload messages
    
    static func uploadTextFromCurrent(phoneMe: String, myName: String, phoneOther: String, otherName: String, message: String, time0: String, time1: String, time2: String, completion: @escaping(String) -> Void) {
        
        let data = [
            "receivingPhone": phoneOther,
            "receivingUsername": otherName,
            "fromPhone": phoneMe,
            "fromUsername": myName,
            "text": message,
            "timeShort": time0,
            "timeLong": time1,
            "timeMin": time2
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(phoneMe).collection("friends").document(phoneOther).collection("messages").document(time1).setData(data) { error in
            
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error upload sending txt \(e)")
                completion(e)
                return
            }
            completion("success")
        }
    }
    
    static func uploadReceivingText(receivePhone: String, receiveName: String, fromPhone: String, fromName: String, message: String, time0: String, time1: String, time2: String, completion: @escaping(String) -> Void) {
        
        let data = [
            "receivingPhone": receivePhone,
            "receivingUsername": receiveName,
            "fromPhone": fromPhone,
            "fromUsername": fromName,
            "text": message,
            "timeShort": time0,
            "timeLong": time1,
            "timeMin": time2
        ] as [String : Any]

        Firestore.firestore().collection("users").document(receivePhone).collection("friends").document(fromPhone).collection("messages").document(time1).setData(data) { error in

            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error upload receiving txt \(e)")
                completion(e)
                return
            }
            completion("success")
        }
    }
    
//MARK: - Upload Conver and status
//we got 4 types of status: the texter only has 2 statuses ("Sent" and "Seen") while the receiver also has 2 ("New messages" and "Received")
    
    static func uploadConverFromTexter(phMe: String, infoFriend: User, time: String, deliStatus: String, timeFull: String, completion: @escaping(String) -> Void) {
        let data = [
            "phoneNumber": infoFriend.phone,
            "username": infoFriend.username,
            "profileImageUrl": infoFriend.profileImageUrl,
            "status": deliStatus,
            "timeRecent": time,
            "timeLong": timeFull
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(phMe).collection("friends").document(infoFriend.phone).setData(data) { error in
            
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error upload conver \(e)")
                completion(e)
                return
            }
            completion("success")
        }
    }
    
    static func uploadConverToReceiver(receiverPh: String, infoTexter: User, time: String, deliStatus: String, timeFull: String, completion: @escaping(String) -> Void) {
        let data = [
            "phoneNumber": infoTexter.phone,
            "username": infoTexter.username,
            "profileImageUrl": infoTexter.profileImageUrl,
            "status": deliStatus,
            "timeRecent": time,
            "timeLong": timeFull
        ] as [String : Any]
        
        //new data will override the old data
        Firestore.firestore().collection("users").document(receiverPh).collection("friends").document(infoTexter.phone).setData(data) { error in
            
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error upload conver \(e)")
                completion(e)
                return
            }
            completion("success")
        }
    }
    
    static func updateStatus(phoneMain: String, phoneSecond: String, newStatus: String) {
        let data = ["status": newStatus] as [String: Any]
        
        Firestore.firestore().collection("users").document(phoneMain).collection("friends").document(phoneSecond).setData(data, merge: true) { error in
            
            if let e = error {
                print("DEBUG-UploadInfo: error update status -  \(e.localizedDescription)")
                return
            }
            print("DEBUG-UploadInfo: done updating status of conver")
        }
    }
    
    
    
}
