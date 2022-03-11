//
//  MapViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/18/21.
//

import UIKit
import Firebase
import SDWebImage

class SettingViewController: UIViewController {
    
    private var phoneUser = Auth.auth().currentUser?.phoneNumber ?? "nil"
    private var changeUserInfoObserver: NSObjectProtocol?
    private var logInObserver: NSObjectProtocol?
    
    private var userStuff = User(dictionary: [:]) {
        didSet {
            displayUserInfo()
        }
    }
    
    private var profileURL: URL? {
        return URL(string: userStuff.profileImageUrl)
    }
    
//MARK: - Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    private let phoneLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .white
        lb.text = "Loading..."
        
        return lb
    }()
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lb.textColor = .white
        lb.text = "Loading..."
        
        return lb
    }()
    
    private let libraryLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .gray
        lb.text = "Loading photos..."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return lb
    }()
    
    private let libraryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Library", for: .normal)
        btn.setTitleColor(.green.withAlphaComponent(0.87), for: .normal)
        btn.backgroundColor = .clear
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(showLibraryVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let friendLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .gray
        lb.text = "Loading friends.."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return lb
    }()
    
    private let friendsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Friends", for: .normal)
        btn.setTitleColor(.green.withAlphaComponent(0.87), for: .normal)
        btn.backgroundColor = .clear
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(showLibraryVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let logoutLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .gray
        lb.text = "Logout"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return lb
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Logout", for: .normal)
        btn.setTitleColor(.white.withAlphaComponent(0.87), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8472645879, green: 0.177804023, blue: 0.1054576561, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.layer.cornerRadius = 14
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(alertLogout), for: .touchUpInside)
        
        return btn
    }()
    

//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        configureNavBar()
        configureUI()
        addTapAndSwipeGesture()
        fetchUserInfo()
        protocolVC()
    }
    
//MARK: - Configuration
    
    private func configureNavBar() {
        let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: "Setting", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissVC))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(showProfileImgVC))
    }
    
    
    private func configureUI() {
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20, width: 180, height: 180)
        profileImageView.layer.cornerRadius = 90
        profileImageView.centerX(inView: view)
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        usernameLabel.centerX(inView: view)
        
        view.addSubview(phoneLabel)
        phoneLabel.anchor(top: usernameLabel.bottomAnchor, paddingTop: 12)
        phoneLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [libraryLabel, libraryButton, friendLabel, friendsButton, logoutLabel, logoutButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .equalSpacing
        
        view.addSubview(stack)
        stack.anchor(top: phoneLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 36, paddingLeft: 32, paddingRight: 32)
    }
    
//MARK: - Protocols
    
    func protocolVC() {
        //protocol from ProfileImageVC
        changeUserInfoObserver = NotificationCenter.default.addObserver(forName: .didChangeUserInfo, object: nil, queue: .main) { [weak self] _ in

            print("DEBUG-SettingVC: Just change user info...")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserInfo()
        }
        //protocol login successfully
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogIn, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-SettingVC: login notified, fetching SettingVC..")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserInfo()
        }
    }
    deinit {
        if let observer1 = changeUserInfoObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        if let observer2 = logInObserver {
            NotificationCenter.default.removeObserver(observer2)
        }
    }
    
//MARK: - Actions
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc func alertLogout() {
        let actionSheet = UIAlertController (title: "Log out?", message: "Are you sure want to log out?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
        actionSheet.addAction(action)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func addTapAndSwipeGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showProfileImg))
        let down = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        down.direction = .down
        profileImageView.addGestureRecognizer(tap)
//        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(down)
    }
   
    @objc func showProfileImgVC() {
        DispatchQueue.main.async {
            let vc = ProfileImageViewController(user: self.userStuff)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    @objc func showProfileImg() {
        DispatchQueue.main.async {
            let vc = BigImageViewController(user: self.userStuff)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func fetchUserInfo() {
        if phoneUser == "nil" {
            if let phone = userDefault.shared.defaults.value(forKey: "currentPhone") as? String {
                print("DEBUG-SettingVC: got phoneNo from userDefault")
                phoneUser = phone
            } else {
                print("DEBUG-SettingVC: no phone number available")
            }
        }
        UserService.fetchUserInfo(phoneFull: phoneUser) { userInfo in
            print("DEBUG-SettingVC: fetching userInfo..")
            self.userStuff = userInfo
            if userInfo.profileImageUrl == "none" {
                self.profileImageView.image = UIImage(systemName: "person.circle")
            }
        }
    }
    
    private func displayUserInfo() {
        if userStuff.profileImageUrl == "none" {
            userNameLetterIV(userName: userStuff.username) { iv in
                self.profileImageView.image = iv.image
                self.profileImageView.tintColor = iv.tintColor
            }
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
        phoneLabel.text = userStuff.phone
        usernameLabel.text = userStuff.username
    }
    
    @objc func showLibraryVC() {
        
    }
    
    
    
    

}
