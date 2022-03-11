//
//  MessageViewModel.swift
//  FireBaseChat
//
//  Created by Long Nguyen on 8/8/20.
//  Copyright © 2020 Long Nguyen. All rights reserved.
//

import UIKit

struct MessageViewModel {
    
    private let messageViewModel: Message //Message is from Message.swift file
    
    var messageBackgroundcolor: UIColor {
        return messageViewModel.isFromCurrentUser ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : .systemPurple
    }
    
    var messageTextColor: UIColor {
        return messageViewModel.isFromCurrentUser ? .black : .white
    }
    
    var rightAnchorActive: Bool {
        return messageViewModel.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !messageViewModel.isFromCurrentUser
    }
    
    var shouldHideProfileImage: Bool {
        return messageViewModel.isFromCurrentUser
    }
    
    var profileImageUrl: String? {
        guard let userProfileImage = messageViewModel.user else { return nil }
        return userProfileImage.profileImageUrl
    }
    
    
    init(message: Message) {
        self.messageViewModel = message //"mesage" is from init
    }
}
