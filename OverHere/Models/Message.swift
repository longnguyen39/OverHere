//
//  Message.swift
//  FireBaseChat
//
//  Created by Long Nguyen on 8/8/20.
//  Copyright © 2020 Long Nguyen. All rights reserved.
//

import UIKit
import Firebase

struct Message {
    let text: String
    let receivingPhone: String
    let receivingUsername: String
    let fromPhone: String
    let fromUsername: String
    var timeShort: String //this is a feature from Firebase
    var timeLong: String
    var timeMin: String
    let isFromCurrentUser: Bool
    
    var user: User?
    var imageUrl: String?
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? "none"
        self.receivingPhone = dictionary["toPhone"] as? String ?? "none"
        self.receivingUsername = dictionary["to"] as? String ?? "none"
        self.fromPhone = dictionary["fromPhone"] as? String ?? "none"
        self.fromUsername = dictionary["toPhone"] as? String ?? "none"
        self.timeShort = dictionary["timeShort"] as? String ?? "none"
        self.timeLong = dictionary["timeLong"] as? String ?? "none"
        self.timeMin = dictionary["timeMin"] as? String ?? "none"
        self.isFromCurrentUser = fromPhone == Auth.auth().currentUser?.phoneNumber
        //those with "" gotta match with the ones in the Service.swift file
    }
}
