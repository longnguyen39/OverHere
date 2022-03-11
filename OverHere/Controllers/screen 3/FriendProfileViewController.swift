//
//  FriendProfileViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 10/31/21.
//

import UIKit
import SDWebImage

class FriendProfileViewController: UIViewController {
    
    var userInfo = User(dictionary: [:])
    
    private var profileURL: URL? {
        return URL(string: userInfo.profileImageUrl)
    }
    
//MARK: - Components
    
    private var profileImageView: UIImageView = {
        let iv  = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.image = UIImage(systemName: "questionmark.circle")
        
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.text = "Loading..."
        
        return lb
    }()
    
    private let phoneNoLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .gray
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.numberOfLines = 1
        lb.text = "Loading..."
        
        return lb
    }()
    
//MARK: - View Scenes
    
    init(user: User) {
        self.userInfo = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        configureNavBar()
        configureUI()
        displayUserInfo()
        swipeGesture()
    }
    
//MARK: - Configuration
    
    private func configureNavBar() {
        let navColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.087)
        configureNavigationBar(title: "Profile", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark) //the "interface" can affect tintColor of SearchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissVC))
        
    }
    
    private func configureUI() {
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 24, width: 180, height: 180)
        profileImageView.layer.cornerRadius = 90
        profileImageView.centerX(inView: view)
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 16)
        usernameLabel.centerX(inView: view)
        
        view.addSubview(phoneNoLabel)
        phoneNoLabel.anchor(top: usernameLabel.bottomAnchor, paddingTop: 12)
        phoneNoLabel.centerX(inView: view)
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
        usernameLabel.text = userInfo.username
        phoneNoLabel.text = userInfo.phone
    }
    
    private func swipeGesture() {
        let down = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        down.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(down)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    
    

}
