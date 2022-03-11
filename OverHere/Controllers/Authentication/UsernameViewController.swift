//
//  UsernameViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/25/21.
//

import UIKit
import Firebase

class UsernameViewController: UIViewController {

    private var viewModel = ViewModelUsername()
    
//MARK: - Components
    
    private let logoIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "tesla")
        iv.tintColor = .black
        iv.clipsToBounds = true
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    
    private let bigView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white.withAlphaComponent(0.87)
        vw.layer.cornerRadius = 12
        
        return vw
    }()
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lb.numberOfLines = .zero
        lb.text = "What should we call you?"
        lb.textColor = .darkText
        lb.textAlignment = .left
        
        return lb
    }()
    
    private let separatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        return vw
    }()
    
    private let usernameTextField: UITextField = {
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 18)
        field.keyboardType = .alphabet
        field.autocapitalizationType = .none
        field.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        return field
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.3928793073, green: 0.7171890736, blue: 0.1947185397, alpha: 1)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        btn.isEnabled = false
        btn.alpha = 0.8
        
        return btn
    }()
    
//MARK: - View scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGradientLayer(from: 0, to: 1)
        configureUI()
        usernameTextField.becomeFirstResponder()
    }
    
    private func configureUI() {
        view.addSubview(logoIcon)
        logoIcon.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20, width: 120, height: 120)
        logoIcon.centerX(inView: view)
        
        //bigView
        view.addSubview(bigView)
        bigView.anchor(top: logoIcon.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 100)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, separatorView, usernameTextField])
        usernameLabel.setHeight(height: 49)
        usernameTextField.setHeight(height: 49)
        separatorView.setHeight(height: 2)
        stack.axis = .vertical
        stack.distribution = .equalCentering
        
        bigView.addSubview(stack)
        stack.anchor(top: bigView.topAnchor, left: bigView.leftAnchor, bottom: bigView.bottomAnchor, right: bigView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        
        //bottom components
        view.addSubview(continueButton)
        continueButton.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 20, height: 50)
        
    }

    
//MARK: - Text validation
        
    @objc func textDidChange(sender: UITextField) {
        viewModel.username = usernameTextField.text ?? ""
        checkFormStatus()
    }
    
    private func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            continueButton.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.7885528207, alpha: 1)
            continueButton.isEnabled = true
            continueButton.alpha = 1
        } else {
            continueButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            continueButton.isEnabled = false
            continueButton.alpha = 0.8
        }
    }
    
//MARK: - Actions
    
    private func alertCustom(error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: buttonNote, style: .default) { _ in
            self.showLoadingView(false)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func continueTapped() {
        guard let charUsername = viewModel.username?.count else { return }
        if charUsername < 2 {
            alertCustom(error: "Username needs to be at least 2 charaters", buttonNote: "Try again")
        }
        
        if viewModel.username == "username..." {
            alertCustom(error: "Please try a different username", buttonNote: "OK")
            return
        }
        
        updateUsername()
        dismiss(animated: true, completion: nil)
    }
    
        
    private func updateUsername() {
        guard let username = viewModel.username else { return }
        guard let phone = Auth.auth().currentUser?.phoneNumber else { return }
        print("DEBUG-UsernameVC: username typed is \(username)")
        
        UserService.updateUsername(phoneFull: phone, newUsername: username) { result in
            switch result {
            case .success(let uName):
                print("DEBUG-UsernameVC: done updating username \(uName)")
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .didLogIn, object: nil) //declared in 3 main VCs
            case .failure(let error):
                let e = error.localizedDescription
                self.alertCustom(error: e, buttonNote: "OK")
                return
            }
        }
    }
    
    

}
