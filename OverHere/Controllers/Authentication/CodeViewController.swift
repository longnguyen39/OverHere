//
//  CodeViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/19/21.
//

import UIKit
import Firebase

class CodeViewController: UIViewController {

    private var viewModel = ViewModelCode()
    
    private var verificationID: String?
    private var phoneNumber: String = ""
    
//MARK: - Components
    
    private let bigLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        lb.text = "OverHere"
        lb.textColor = .black
        lb.textAlignment = .center
        
        return lb
    }()
    
    
    private let codeView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 12
        
        return vw
    }()
    
    private let codeInstructionLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.numberOfLines = .zero
        lb.text = "Please check your SMS for your code."
        lb.textColor = .brown
        lb.textAlignment = .left
        
        return lb
    }()
    
    private let separatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        return vw
    }()
    
    private let codeTextField: UITextField = {
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 18)
        field.keyboardType = .numberPad
        field.attributedPlaceholder = NSAttributedString(string: "Code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.textColor = .black
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        return field
    }()
    
    private let dontReceiveCodeButton: UIButton = {
        let btn = UIButton(type: .system)
        let textColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let attributedTitle = NSMutableAttributedString (string: "Don't receive code?  ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: textColor])
        
        attributedTitle.append(NSMutableAttributedString(string: "let's go back!", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.yellow]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(backToPhoneVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.3928793073, green: 0.7171890736, blue: 0.1947185397, alpha: 1)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        btn.addTarget(self, action: #selector(verifyAndLogin), for: .touchUpInside)
        btn.isEnabled = false
        btn.alpha = 0.8
        
        return btn
    }()
    
    
//MARK: - View Scene
    
    init(veriID: String, phone: String) {
        self.verificationID = veriID
        self.phoneNumber = phone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGradientLayer(from: 0, to: 1)
        configureUI()
        codeTextField.becomeFirstResponder()
    }
    
    private func configureUI() {
        view.addSubview(bigLabel)
        bigLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 40)
        bigLabel.centerX(inView: view)
        
        //code view
        view.addSubview(codeView)
        codeView.anchor(top: bigLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 100)
        
        let stack = UIStackView(arrangedSubviews: [codeInstructionLabel, separatorView, codeTextField])
        codeInstructionLabel.setHeight(height: 49)
        codeTextField.setHeight(height: 49)
        separatorView.setHeight(height: 2)
        stack.axis = .vertical
        stack.distribution = .equalCentering
        
        codeView.addSubview(stack)
        stack.anchor(top: codeView.topAnchor, left: codeView.leftAnchor, bottom: codeView.bottomAnchor, right: codeView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        
        //bottom components
        let stackBottom = UIStackView(arrangedSubviews: [signInButton, dontReceiveCodeButton])
        signInButton.setHeight(height: 50)
        stackBottom.axis = .vertical
        stackBottom.spacing = 20
        view.addSubview(stackBottom)
        stackBottom.anchor(top: codeView.bottomAnchor, left: codeView.leftAnchor, right: codeView.rightAnchor, paddingTop: 20)
        
    }
    
//MARK: - Text validation
    
    @objc func textDidChange(sender: UITextField) {
        viewModel.code = codeTextField.text ?? ""
        checkFormStatus()
    }
    
    private func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            signInButton.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.7885528207, alpha: 1)
            signInButton.isEnabled = true
            signInButton.alpha = 1
        } else {
            signInButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            signInButton.isEnabled = false
            signInButton.alpha = 0.8
        }
    }
    
//MARK: - Action
    
    private func alertCustom(error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: buttonNote, style: .default) { _ in
            self.showLoadingView(false)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func verifyAndLogin() {
        print("DEBUG-CodeVC: signing user in...")
        showLoadingView(true)
        guard let code = codeTextField.text else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "no id", verificationCode: code)
        
        Auth.auth().signIn(with: credential) { result, error in            
            if let e = error?.localizedDescription {
                print("DEBUG-CodeVC: \(e)")
                self.alertCustom(error: e, buttonNote: "Try again")
                return
            }
            self.checkUserExist()
        }
        
    }
    
    private func checkUserExist() {
        UserService.fetchUsers(phoneFull: self.phoneNumber) { newUser in
            print("DEBUG-CodeVC: creating new user is \(newUser)")
            if newUser {
                UserService.createNewUser(phone: self.phoneNumber) { result in
                    switch result {
                    case .success(let newPhone):
                        print("DEBUG-CodeVC: successfully log in with \(newPhone)")
                        self.doneSigningIn()
                    case .failure(let error):
                        let e = error.localizedDescription
                        self.alertCustom(error: e, buttonNote: "OK")
                        return
                    }
                }
            } else {
                print("DEBUG-CodeVC: no need to create new user")
                self.doneSigningIn()
            }
        }
    }
    
    private func doneSigningIn() {
        self.showLoadingView(false)
        userDefault.shared.defaults.set(phoneNumber, forKey: "currentPhone") //save it so we can use it when this VC is dismissed
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .checkUsername, object: nil) //declared in ScrollVC
    }
    
    
    @objc func backToPhoneVC() {
        navigationController?.popViewController(animated: true)
    }
    

}
