//
//  Conversation.swift
//  FireBaseChat
//
//  Created by Long Nguyen on 8/10/20.
//  Copyright © 2020 Long Nguyen. All rights reserved.
//

import UIKit

//this is just the recent messages
struct Conversation {
    let phoneNo: String
    let imageUrl: String
    let status: String
    let username: String
    var timeLong: String
    var timeRecent: String
    
    init(dictionary: [String: Any]) {
        self.phoneNo = dictionary["phoneNumber"] as? String ?? "none"
        self.imageUrl = dictionary["profileImageUrl"] as? String ?? "none"
        self.status = dictionary["status"] as? String ?? "none"
        self.username = dictionary["username"] as? String ?? "none"
        self.timeLong = dictionary["timeLong"] as? String ?? "none"
        self.timeRecent = dictionary["timeRecent"] as? String ?? "none"
        
        //those with "" gotta match with the ones in the Service.swift file
    }
}
