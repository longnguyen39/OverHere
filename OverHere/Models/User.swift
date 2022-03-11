//
//  User.swift
//  GoChat
//
//  Created by Long Nguyen on 8/8/21.
//

import UIKit
import Firebase

struct User {
    var phone: String
    var username: String
    var profileImageUrl: String
    
    init(dictionary: [String : Any]) {
        self.phone = dictionary["phoneNumber"] as? String ?? "none"
        self.username = dictionary["username"] as? String ?? "none"
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? "no imageURL"
        //all the shit "" must match the "" in "data" in AuthService
    }
    
}
