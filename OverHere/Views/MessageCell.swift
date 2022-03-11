//
//  MessageCell.swift
//  FireBaseChat
//
//  Created by Long Nguyen on 8/7/20.
//  Copyright © 2020 Long Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

class MessageCell: UICollectionViewCell {
    
//MARK: - Components
    
    var messageCell: Message? {
        didSet {
            configure()
        }
    }
    
    private var profileURL: URL? {
        return URL(string: messageCell?.user?.profileImageUrl ?? "none")
    }
    
    
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.setDimensions(height: 32, width: 32)
        iv.layer.cornerRadius = 16
        
        return iv
    }()
    
    private let bubbleContainer: UIView = {
        let viewBubble = UIView()
        viewBubble.backgroundColor = .systemPurple
        viewBubble.layer.cornerRadius = 12
        
        return viewBubble
    }()
    
    private let timeLabelOnLeft: UILabel = {
        let lb = UILabel()
        lb.text = "0:00 am"
        lb.textColor = .lightGray
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        return lb
    }()
    
    private let timeLabelOnRight: UILabel = {
        let lb = UILabel()
        lb.text = "0:00 am"
        lb.textColor = .lightGray
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        return lb
    }()
    
    //this plays a role as "UILabel"
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 18)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textColor = .white
        tv.text = "some messages"
        
        return tv
    }()
    
    
  
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        //backgroundColor = .red
        
        //now construct the message bubble UI
        addSubview(profileImageView) //addSubview to each message bubble
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        
        addSubview(bubbleContainer)
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor) //gotta have the bottom anchor so that long messages DONT overlaps the next messages
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 2, paddingRight: 8)
        
        //now the time label
        addSubview(timeLabelOnLeft)
        timeLabelOnLeft.anchor(bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.leftAnchor, paddingRight: 4)
        
        addSubview(timeLabelOnRight)
        timeLabelOnRight.anchor(left: bubbleContainer.rightAnchor, bottom: bubbleContainer.bottomAnchor, paddingLeft: 4)
        
        //set the constraints and positions for messageBubble
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleLeftAnchor.isActive = false
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleRightAnchor.isActive = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Helpers
    
    func configure() {
        guard let messagess = messageCell else { return }
        let viewModel = MessageViewModel(message: messagess) //from a swift file

        bubbleContainer.backgroundColor = viewModel.messageBackgroundcolor
        textView.textColor = viewModel.messageTextColor
        textView.text = messagess.text

        //set the anchors based on user sending status
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        timeLabelOnLeft.isHidden = bubbleLeftAnchor.isActive ? true : false
        timeLabelOnRight.isHidden = bubbleRightAnchor.isActive ? true : false
        
        profileImageView.isHidden = viewModel.shouldHideProfileImage //when the message is sent from you, then the profileImage will be hidden
//        profileImageView.isHidden = true
        
        timeLabelOnLeft.text = messageCell?.timeMin
        timeLabelOnRight.text = messageCell?.timeMin
        
        if viewModel.profileImageUrl == "none" {
            userNameLetterIV(userName: messageCell?.user?.username ?? "") { iv in
                self.profileImageView.image = iv.image
                self.profileImageView.tintColor = iv.tintColor
            }
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    
}
