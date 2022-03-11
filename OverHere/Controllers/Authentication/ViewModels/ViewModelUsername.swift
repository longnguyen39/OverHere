//
//  ViewModelUsername.swift
//  OverHere
//
//  Created by Long Nguyen on 9/25/21.
//

import Foundation

struct ViewModelUsername {
    
    var username: String?
    
    var formIsValid: Bool {
        return username?.isEmpty == false
    }
}
