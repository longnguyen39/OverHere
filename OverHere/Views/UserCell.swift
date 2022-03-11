//
//  UserCell.swift
//  OverHere
//
//  Created by Long Nguyen on 10/23/21.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {
        
    let imgHeight: CGFloat = 56
    let arrowHeight: CGFloat = 28
    
    var userInfo = User(dictionary: [:]) {
        didSet {
            displayUserInfo()
        }
    }
    
    private var profileURL: URL? {
        return URL(string: userInfo.profileImageUrl)
    }
    
    var currentUserInfo = User(dictionary: [:]) {
        didSet {
            checkNoteToSelf()
        }
    }
    
//MARK: - Components
    
    private var profileImageView: UIImageView = {
        let iv  = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.image = #imageLiteral(resourceName: "tesla")
        
        return iv
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "chevron.right.circle")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .green
        
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.text = "Venom"
        
        return lb
    }()
    
    private let phoneNoLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .gray
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.numberOfLines = 1
        lb.text = "+19998887777"
        
        return lb
    }()

//MARK: - View Scenes

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .black
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12, width: imgHeight, height: imgHeight)
        profileImageView.layer.cornerRadius = imgHeight/2
        profileImageView.centerY(inView: self)
        
        addSubview(arrowImageView)
        arrowImageView.anchor(right: rightAnchor, paddingRight: 8, width: arrowHeight, height: arrowHeight)
        arrowImageView.centerY(inView: self)
        
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, phoneNoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading //anchor to the left
        addSubview(stackView)
        stackView.anchor(left: profileImageView.rightAnchor, right: arrowImageView.leftAnchor, paddingLeft: 8, paddingRight: 8)
        stackView.centerY(inView: profileImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    private func displayUserInfo() {
        if userInfo.profileImageUrl == "none" {
            userNameLetterIV(userName: userInfo.username) { iv in
                self.profileImageView.image = iv.image
                self.profileImageView.tintColor = iv.tintColor
            }
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
        phoneNoLabel.text = userInfo.phone
    }
    
    private func checkNoteToSelf() {
        if userInfo.phone == currentUserInfo.phone {
            usernameLabel.text = "\(userInfo.username) (me)"
            profileImageView.image = UIImage(systemName: "note.text")
            profileImageView.tintColor = .gray
            profileImageView.layer.cornerRadius = 0
        } else {
            usernameLabel.text = userInfo.username
            profileImageView.layer.cornerRadius = imgHeight/2
        }
    }
    
    
}
