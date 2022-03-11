//
//  ViewModelSignUp.swift
//  GoChat
//
//  Created by Long Nguyen on 8/3/21.
//

import Foundation

struct ViewModelCode {
    
    var code: String = ""
    
    var formIsValid: Bool {
        return code.count == 6
    }
}
