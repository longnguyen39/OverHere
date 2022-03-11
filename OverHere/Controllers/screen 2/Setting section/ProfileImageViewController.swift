//
//  ProfileImageViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 10/17/21.
//

import UIKit
import Firebase
import SDWebImage

class ProfileImageViewController: UIViewController {

    var userInfo = User(dictionary: [:])
    
    private var profileURL: URL? {
        return URL(string: userInfo.profileImageUrl)
    }
    
//MARK: - Components
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lb.textColor = .green
        lb.textAlignment = .center
        lb.text = "Loading.."
        
        return lb
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let changeImgButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change Image", for: .normal)
        
        if #available(iOS 15.0, *) {
            btn.configuration = .filled()
            btn.configuration?.cornerStyle = .medium
            btn.configuration?.baseForegroundColor = .green
            btn.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.15)
        } else {
            btn.setTitleColor(.green.withAlphaComponent(0.87), for: .normal)
            btn.backgroundColor = .clear
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(changeProfileImage), for: .touchUpInside)
        
        return btn
    }()
    
    private let changeNameButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change Username", for: .normal)
        
        if #available(iOS 15.0, *) {
            btn.configuration = .filled()
            btn.configuration?.cornerStyle = .medium
            btn.configuration?.baseForegroundColor = .green
            btn.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.15)
        } else {
            btn.setTitleColor(.green.withAlphaComponent(0.87), for: .normal)
            btn.backgroundColor = .clear
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(textBoxUsername), for: .touchUpInside)
        
        return btn
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
        configureUI()
        configureNavBar()
        swipeGesture()
        displayUserInfo()
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
//MARK: - Configuration
    
    private func configureNavBar() {
        let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: "Edit Profile", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissVC))
    }
    
    private func configureUI() {
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: usernameLabel.bottomAnchor, paddingTop: 20, width: 240, height: 240)
        profileImageView.layer.cornerRadius = 240 / 2
        profileImageView.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [changeImgButton, changeNameButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
    }
    
    private func swipeGesture() {
        let down = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        down.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(down)
    }
    
//MARK: - Actions
    
    private func displayUserInfo() {
        usernameLabel.text = userInfo.username
        if userInfo.profileImageUrl == "none" {
            userNameLetterIV(userName: userInfo.username) { iv in
                self.profileImageView.image = iv.image
                self.profileImageView.tintColor = iv.tintColor
            }
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    @objc func changeProfileImage() {
        print("DEBUG-ProfileImageVC: changing profile img..")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    private func uploadNewProfileImage() {
        guard let newImage = profileImageView.image else { return }
        let phoneNo = userInfo.phone
        
        UploadInfo.uploadProfileImage(image: newImage, phone: phoneNo) { imageUrl in
            
            let data = ["profileImageUrl": imageUrl]
            
            Firestore.firestore().collection("users").document(phoneNo).updateData(data) { error in

                self.showLoadingView(false, message: "Saving..")
                if let e = error?.localizedDescription {
                    print("DEBUG-SettingVC: error changing proImage - \(e)")
                    self.alert(error: "Oops, \(e)", buttonNote: "Try again")
                    return
                }
                print("DEBUG-ProfileImageVC: finish uploading new profileImage")

                //send notification to SettingVC
                NotificationCenter.default.post(name: .didChangeUserInfo, object: nil)
            }
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    
//MARK: - Text box and username
    
    @objc func textBoxUsername() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Edit Username", message: "Please enter new a username", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                self.showLoadingView(true)
                let new = textField.text!
                self.updateUsername(newName: new)
            } else {
                print("DEBUG: textField is empty..")
                self.alert(error: "Please enter a valid input", buttonNote: "Try again")
            }
        }
        
        alertBox.addTextField { (alertTextField) in
            alertTextField.placeholder = "Username..."
            alertTextField.text = self.userInfo.username
            textField = alertTextField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    private func updateUsername(newName: String) {
        UserService.updateUsername(phoneFull: userInfo.phone, newUsername: newName) { result in
            
            self.showLoadingView(false)
            switch result {
            case .success(let uName):
                print("DEBUG-ProfileImageVC: just update username \(uName)")
                self.usernameLabel.text = uName
                NotificationCenter.default.post(name: .didChangeUserInfo, object: nil) //send notifi to SettingVC
            case .failure(let error):
                let e = error.localizedDescription
                self.alert(error: e, buttonNote: "OK")
                return
            }
        }
    }
    

}

//MARK: - Extension for ImagePicker

extension ProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //this func gets called once user has just chose a pict
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("DEBUG-ProfileImageVC: just finished picking a photo")
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("DEBUG-ProfileImageVC: error setting selectedImage")
            return
        }
        
        //let's set the profileImageView as the selected image
        profileImageView.image = selectedImage
        showLoadingView(true, message: "Saving..")
        uploadNewProfileImage()
        self.dismiss(animated: true, completion: nil)
    }
}
