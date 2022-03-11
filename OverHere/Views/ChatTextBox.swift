//
//  ChatTextBox.swift
//  OverHere
//
//  Created by Long Nguyen on 10/31/21.
//

import UIKit

protocol ChatTextBoxDelegate: AnyObject {
    func inputView(wantsToSend text: String)
    func takeAPict()
    func sendAPict()
}

class ChatTextBox: UIView {
    
    weak var delegate: ChatTextBoxDelegate?
    
    let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
    
//MARK: - Components
    
    //textField has 1 line of words, textView has infinite lines, but no placeholder
    lazy var messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.returnKeyType = .send
        tv.keyboardType = .alphabet //need this to hide the "suggestion toolbar"
        tv.autocorrectionType = .no
        tv.keyboardAppearance = .dark
        tv.autocapitalizationType = .none
        tv.tintColor = .green
        tv.textColor = .white
        tv.backgroundColor = #colorLiteral(red: 0.3601109385, green: 0.3249934316, blue: 0.3292433321, alpha: 1) //black without full opacity
        tv.textContainer.maximumNumberOfLines = 8
        //now give the padding so texts wont flush into the left side
        tv.textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Message"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lightGray
        
        return label
    }()
    
    //lazy var cuz it's in the UIView and we want ot add the target (set func for the button)
    private lazy var sendPictButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.tintColor = .green.withAlphaComponent(0.87)
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(sendPict), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var takePictButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
        btn.tintColor = .green.withAlphaComponent(0.87)
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(takePict), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        messageInputTextView.delegate = self
        
        //let's handle the placeholder text (it disappears when you type in it)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //this func will figure out the right size
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func configureUI() {
        backgroundColor = navColor
        autoresizingMask = .flexibleHeight //just put this line here for safety
        
        layer.shadowOpacity = 0.37
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowRadius = 10
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 46, paddingBottom: 8, paddingRight: 46)
        messageInputTextView.layer.cornerRadius = 16
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 10)
        placeholderLabel.centerY(inView: messageInputTextView)
        
        addSubview(takePictButton)
        takePictButton.anchor(left: leftAnchor, bottom: messageInputTextView.bottomAnchor, right: messageInputTextView.leftAnchor, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, height: 28)
        
        addSubview(sendPictButton)
        sendPictButton.anchor(left: messageInputTextView.rightAnchor, bottom: messageInputTextView.bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, height: 28)
    }
    
//MARK: - Actions
    
    //this func hides the placeholder when you type
    @objc func handleTextInputChange () {
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
        
        if messageInputTextView.text.count > 200 {
            messageInputTextView.deleteBackward() //user cannot type more
        }
    }
    
    private func keyboardActive() {
        
    }
    
    private func sendMessage () {
        guard let messageSent = messageInputTextView.text else { return }
        delegate?.inputView(wantsToSend: messageSent) //delegate to TextVC
        clearMessageText()
    }
    
    private func clearMessageText () {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    @objc func takePict() {
        delegate?.takeAPict()
    }
    
    @objc func sendPict() {
        delegate?.sendAPict()
    }
    
    
}

//MARK: - Protocol textField
//this is the default protocol for textField in Swift
//Remember to write ".delegate = self"
extension ChatTextBox: UITextViewDelegate {
    //this gets called whenever u type
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let cnt = messageInputTextView.text.count
        print("DEBUG-ChatTextBox: character count is \(cnt + 1)") //start from 0
        if text == "\n" { //this is what happens if u type "return" key
            sendMessage()
            return false
        }
        return true
    }
    
    
    
}
