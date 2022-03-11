//
//  ViewModelLogIn.swift
//  GoChat
//
//  Created by Long Nguyen on 8/3/21.
//

import Foundation

struct ViewModelPhone {
    
    var phoneNumber: String = ""
    
    var formIsValid: Bool {
        return phoneNumber.count >= 9
    }
}
