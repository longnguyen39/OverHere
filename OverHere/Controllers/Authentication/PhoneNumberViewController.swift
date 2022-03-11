//
//  PhoneNumberViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/19/21.
//

import UIKit
import Firebase

class PhoneNumberViewController: UIViewController {

    private var viewModel = ViewModelPhone()
    
    private var phoneNumber: Int = 1
    private var countryCode: String = "+1"
    private var verificationID: String?
    
//MARK: - Components
    
    private let bigLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        lb.text = "OverHere"
        lb.textColor = .black
        lb.textAlignment = .center
        
        return lb
    }()
    
    private let bigView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white.withAlphaComponent(0.87)
        
        return vw
    }()
    
    private let separatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        return vw
    }()
    
    private let codeSeView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        return vw
    }()
    
    private let countryImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "tesla")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .black //image's color is black
        
        return iv
    }()
    
    private let countryLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        lb.text = "United States"
        lb.textColor = .black
        lb.textAlignment = .left
        
        return lb
    }()
    
    private let arrowIndicator: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = UIImage(systemName: "chevron.right.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .black
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let countryCodeLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lb.text = "+1"
        lb.textColor = .black
        lb.textAlignment = .right
        
        return lb
    }()
    
    let phoneTextField: UITextField = {
        let field = UITextField()
        field.font = UIFont.systemFont(ofSize: 18)
        field.keyboardType = .numberPad
        field.attributedPlaceholder = NSAttributedString(string: "Phone number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.textColor = .black
        field.setHeight(height: 30)
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
    
//MARK: - View Scene
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        configureGradientLayer(from: 0, to: 1)
        configureUI()
        phoneTextField.becomeFirstResponder()
    }
    
    private func configureUI() {
        view.addSubview(bigLabel)
        bigLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 40)
        bigLabel.centerX(inView: view)
        
        //bigView
        view.addSubview(bigView)
        bigView.anchor(top: bigLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 102)
        bigView.layer.cornerRadius = 12
        
        bigView.addSubview(separatorView)
        separatorView.anchor(left: bigView.leftAnchor, right: bigView.rightAnchor, height: 2)
        separatorView.centerY(inView: bigView)
        
        //upper view
        bigView.addSubview(countryImageView)
        countryImageView.anchor(top: bigView.topAnchor, left: bigView.leftAnchor, paddingTop: 10, paddingLeft: 12, width: 40, height: 30)
        
        bigView.addSubview(arrowIndicator)
        arrowIndicator.anchor(right: bigView.rightAnchor, paddingRight: 8, width: 30, height: 30)
        arrowIndicator.centerY(inView: countryImageView)
        
        bigView.addSubview(countryLabel)
        countryLabel.anchor(left: countryImageView.rightAnchor, right: arrowIndicator.leftAnchor, paddingLeft: 8, paddingRight: 8)
        countryLabel.centerY(inView: countryImageView)
        
        //lower view
        bigView.addSubview(codeSeView)
        codeSeView.anchor(top: separatorView.bottomAnchor, bottom: bigView.bottomAnchor, right: countryImageView.rightAnchor, paddingTop: 10, paddingBottom: 10, width: 1)
        
        bigView.addSubview(countryCodeLabel)
        countryCodeLabel.anchor(left: bigView.leftAnchor, right: codeSeView.leftAnchor, paddingLeft: 8, paddingRight: 8)
        countryCodeLabel.centerY(inView: codeSeView)
        
        bigView.addSubview(phoneTextField)
        phoneTextField.anchor(left: codeSeView.rightAnchor, right: bigView.rightAnchor, paddingLeft: 8, paddingRight: 8)
        phoneTextField.centerY(inView: codeSeView)
        
        //continue button
        view.addSubview(continueButton)
        continueButton.anchor(top: bigView.bottomAnchor, left: bigView.leftAnchor, right: bigView.rightAnchor, paddingTop: 24, height: 50)
    }
    
//MARK: - Text validation
    
    @objc func textDidChange(sender: UITextField) {
        viewModel.phoneNumber = phoneTextField.text ?? ""
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
    
//MARK: - Action
    
    private func alertCustom(error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: buttonNote, style: .default) { _ in
            self.showLoadingView(false)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func continueTapped() {
        print("DEBUG-PhoneNumberVC: sending code..")
        showLoadingView(true)
        
        guard let phoneNo = phoneTextField.text else { return }
        let fullPhoneNumber = "\(countryCode)\(phoneNo)"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { id, error in
            
            if let e = error?.localizedDescription {
                print("DEBUG-PhoneNumberVC: oops, \(e)")
                self.alertCustom(error: e, buttonNote: "Try again")
                return
            } else {
                print("DEBUG-PhoneNumberVC: done send code")
                guard let verifyId = id else { return }
                let vc = CodeViewController(veriID: verifyId, phone: fullPhoneNumber)
                
                self.showLoadingView(false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    
   
}
