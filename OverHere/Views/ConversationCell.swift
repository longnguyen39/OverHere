//
//  ConversationCell.swift
//  FireBaseChat
//
//  Created by Long Nguyen on 8/10/20.
//  Copyright © 2020 Long Nguyen. All rights reserved.
//

import UIKit

//make delegate back to ChatVC
protocol ConversationCellDelegate: AnyObject {
    func arrangeConver(idx: Int)
}

//let's build the UI for our ConversationCell
class ConversationCell: UITableViewCell {
    
    weak var delegate: ConversationCellDelegate?
    
    var index: Int = 0
    
    var conversations: Conversation? {
        didSet { configure() }
    }
    
    private var profileURL: URL? {
        return URL(string: conversations?.imageUrl ?? "none")
    }
    
//MARK: - Components
    
    private let bigProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .green
        iv.image = UIImage(systemName: "figure.wave")
        iv.backgroundColor = .clear
        iv.setDimensions(height: 56, width: 56)
        iv.layer.cornerRadius = 56 / 2
    
        return iv
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = "12:30 am"
        
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Wolverine"
        
       return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .gray
        label.text = "Sending..."
        
       return label
    }()
    
    private let statusImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .blue
        iv.image = UIImage(systemName: "message")
        iv.backgroundColor = .clear
        iv.setDimensions(height: 18, width: 20)
    
        return iv
    }()
    
    private let sepaView: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.4715960026, green: 0.46879673, blue: 0.4737505317, alpha: 1).withAlphaComponent(0.27)
        
        return v
    }()
    
    
//MARK: - View Scenes
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(bigProfileImageView)
        bigProfileImageView.anchor(left: leftAnchor, paddingLeft: 12)
        bigProfileImageView.centerY(inView: self)
        
        let stackH = UIStackView(arrangedSubviews: [statusImageView, statusLabel, timestampLabel])
        stackH.axis = .horizontal
        stackH.spacing = 2
        
        let stackV = UIStackView(arrangedSubviews: [usernameLabel, stackH])
        stackV.axis = .vertical
        stackV.spacing = 8
        
        addSubview(stackV)
        stackV.centerY(inView: self)
        stackV.anchor(left: bigProfileImageView.rightAnchor, paddingLeft: 12)
        
        addSubview(sepaView)
        sepaView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    //Sent, Received, Seen, New chats
    func configure() {
        guard let status = conversations?.status else { return }
        if status == "Sent" {
            statusImageView.image = UIImage(systemName: "paperplane.fill")
            statusImageView.tintColor = .yellow
            statusLabel.textColor = .gray
            statusLabel.font = UIFont.systemFont(ofSize: 16)
        } else if status == "Received" {
            statusImageView.image = UIImage(systemName: "bubble.left")
            statusImageView.tintColor = .cyan
            statusLabel.textColor = .gray
            statusLabel.font = UIFont.systemFont(ofSize: 16)
        } else if status == "Seen" {
            statusImageView.image = UIImage(systemName: "envelope.open.fill")
            statusImageView.tintColor = #colorLiteral(red: 0.2523168623, green: 0.3747558296, blue: 0.8766699433, alpha: 1)
            statusLabel.textColor = .gray
            statusLabel.font = UIFont.systemFont(ofSize: 16)
        } else if status == "New chats" {
            statusImageView.image = UIImage(systemName: "envelope.badge")
            statusImageView.tintColor = .green
            statusLabel.textColor = .green
            statusLabel.font = UIFont.boldSystemFont(ofSize: 18)
            delegate?.arrangeConver(idx: index)
        }
        
        statusLabel.text = " \(status): "
        usernameLabel.text = conversations?.username
        timestampLabel.text = conversations?.timeRecent
        
        //let's set the profile image
        if conversations?.imageUrl == "none" {
            userNameLetterIV(userName: conversations?.username ?? "none") { iv in
                self.bigProfileImageView.image = iv.image
                self.bigProfileImageView.tintColor = iv.tintColor
            }
        } else {
            bigProfileImageView.sd_setImage(with: profileURL)
        }
    }
    
    
}
