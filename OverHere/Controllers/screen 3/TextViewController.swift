//
//  Text1CollectionViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 11/5/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessageCell"

protocol TextViewControllerDelegate: AnyObject {
    func moveSentToTop(idx: Int)
}

class TextViewController: UICollectionViewController {
    
    weak var delegate: TextViewControllerDelegate?
    
    private var keyboardHelper: KeyboardHelper?
    private var keyboardPopUp = 0
    private var scroll: Bool = true {
        didSet {
            print("DEBUG-TextVC: scroll is \(scroll)")
        }
    }
    
    private let textingUser: User
    private let meUser: User
    private var tapOrNot: Bool = false //for message notifi
    private var indexUser = 0
    private var readOnce = 0 //for message notifi
    
    private var messagesChat = [Message]()
    var fromCurrentUser = false
    
//MARK: - Components
    
    private lazy var customInputView: ChatTextBox = {
        let iv = ChatTextBox(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        
        return iv
    }()
    
    private let profileButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        
        return btn
    }()
    
    //let's make the default img if there is no text
    private let noMessImageView: UIView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "ellipsis.bubble")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .green.withAlphaComponent(0.87)
        
        return iv
    }()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.text = "No message here yet"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        lb.textColor = .gray
        lb.textAlignment = .center
        
        return lb
    }()
        
//MARK: - View Scenes
    
    //when you use the collectionView, gotta have this line
    init(otherUser: User, me: User, didTap: Bool, index: Int) {
        self.textingUser = otherUser
        self.meUser = me
        self.tapOrNot = didTap
        self.indexUser = index
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureUI()
        setImageNoText()
        fetchMessages()
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0) //setting bottom padding for message
        keyBoardObserver()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //put it here to make the screen switch quicker
        textingUser.profileImageUrl == "none" ? customBtnWithoutUrl() :  customBtnWithUrl()
//        customInputView.messageInputTextView.becomeFirstResponder()
    }
    
    //need this one for textBox since it make keyboard handling much easier
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
//MARK: - Configuration
    
    private func configureNavBar() {
        let navCo = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: textingUser.username, preferLargeTitle: false, backgroundColor: navCo, buttonColor: .green, interface: .dark) //the "interface" can affect tintColor of SearchBar
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(popBackVC))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .done, target: self, action: #selector(showProfile)) //default profile btn
    }
    
    func configureUI () {
        collectionView.backgroundColor = .black
        print("DEBUG-TextVC: username in textVC is \(textingUser.username)")
        
        //let's add the datasource to our UI
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true //no idea for this line
        collectionView.keyboardDismissMode = .interactive //the keyboard dismisses when you scroll down
        
    }
    
//MARK: - APIs
    
    private func fetchMessages() {
        FetchingStuff.fetchMessages(currentUser: meUser, otherUser: textingUser) { messArr in
            var messFetchArr = [Message]()
            let mess = messArr.count
            if mess > 10 {
                print("DEBUG-TextVC: more than 15 mess")
                for i in 1...10 {
                    let idx = mess - 1 - (10 - i)
                    messFetchArr.append(messArr[idx])
                }
                self.messagesChat = messFetchArr
            } else {
                print("DEBUG-TextVC: less than 15 mess")
                self.messagesChat = messArr
            }
//            self.messagesChat = messArr
            self.configureFetching(count: mess)
        }
    }
    
    private func configureFetching(count: Int) {
        fetchStatus()
        collectionView.backgroundView?.isHidden = count > 0
        collectionView.reloadData()
        collectionView.scrollToItem(at: [0, self.messagesChat.count - 1], at: .bottom, animated: true)
    }
    
    private func fetchStatus() {
        FetchingStuff.fetchStatus(firstUser: meUser, secondUser: textingUser) { conver in
            if conver.status == "New chats" && self.readOnce < 1 && self.tapOrNot {
                self.markRead()
                self.readOnce += 1
            }
        }
    }
    
    private func markRead() {
        print("DEBUG-TextVC: just read new message(s)")
        //update status on receiver side
        UploadInfo.updateStatus(phoneMain: meUser.phone, phoneSecond: textingUser.phone, newStatus: "Received")
        //now we do on the sender side
        UploadInfo.updateStatus(phoneMain: textingUser.phone, phoneSecond: meUser.phone, newStatus: "Seen")
        
    }
    
    private func handleError(result: String) {
        if result != "success" {
            self.alertCustom(error: result, buttonNote: "OK")
        } else {
            print("DEBUG-TextVC: done uploading sending message")
        }
    }
    
    private func sendMessage(txt: String) {
        let otherPh = textingUser.phone
        let otherN = textingUser.username
        let mePh = meUser.phone
        let meName = meUser.username
        
        Time.configureTimeNow { timeArr in
            UploadInfo.uploadTextFromCurrent(phoneMe: mePh, myName: meName, phoneOther: otherPh, otherName: otherN, message: txt, time0: timeArr[0], time1: timeArr[1], time2: timeArr[2]) { outcome in
                self.handleError(result: outcome)
            }
            
            UploadInfo.uploadConverFromTexter(phMe: mePh, infoFriend: self.textingUser, time: timeArr[2], deliStatus: "Sent", timeFull: timeArr[1]) { outcome in
                self.handleError(result: outcome)
            }
            
            UploadInfo.uploadConverToReceiver(receiverPh: otherPh, infoTexter: self.meUser, time: timeArr[2], deliStatus: "New chats", timeFull: timeArr[1]) { outcome in
                self.handleError(result: outcome)
            }
            
            UploadInfo.uploadReceivingText(receivePhone: otherPh, receiveName: otherN, fromPhone: mePh, fromName: meName, message: txt, time0: timeArr[0], time1: timeArr[1], time2: timeArr[2]) { result in
                if result != "success" {
                    self.alertCustom(error: result, buttonNote: "OK")
                } else {
                    print("DEBUG-TextVC: done uploading receiving")
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
    
//MARK: - Actions
    
    private func setImageNoText() {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.addSubview(noMessImageView)
        noMessImageView.anchor(top: vw.topAnchor, paddingTop: 160, width: 120, height: 120)
        noMessImageView.centerX(inView: vw)
        vw.addSubview(label)
        label.anchor(top: noMessImageView.bottomAnchor, paddingTop: 8)
        label.centerX(inView: vw)
        collectionView.backgroundView = vw
    }
    
    private func alertCustom(error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: buttonNote, style: .default) { _ in
            self.collectionView.reloadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func customBtnWithoutUrl() {
        userNameLetterIV(userName: textingUser.username) { iv in
            self.profileButton.setBackgroundImage(iv.image, for: .normal)
            self.profileButton.tintColor = iv.tintColor
            self.profileButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.profileButton)
        }
    }
    
    private func customBtnWithUrl() {
        let imageData = try? Data(contentsOf: URL(string : textingUser.profileImageUrl)!)
        if let imageData = imageData , let image =  UIImage(data: imageData)?.resizeImage(to: profileButton.frame.size) {
            profileButton.setBackgroundImage(image, for: .normal)
        }
        profileButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    @objc func showProfile() {
        let vc = FriendProfileViewController(user: textingUser)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func popBackVC() {
        tapOrNot = false //for message notifi
        FetchingStuff.fetchStatus(firstUser: meUser, secondUser: textingUser) { conver in
            if conver.status == "New chats" {
//                UploadInfo.updateStatus(phoneMain: self.meUser.phone, phoneSecond: self.textingUser.phone, newStatus: "Received")
//                UploadInfo.updateStatus(phoneMain: self.textingUser.phone , phoneSecond: self.meUser.phone, newStatus: "Seen")
            } //else if conver.status == "Sent" {
//                if self.indexUser != -1 {
//                    self.delegate?.moveSentToTop(idx: self.indexUser)
//                }
//            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func keyBoardObserver() {
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
                switch animation {
                case .keyboardWillShow:
                    if scroll {
                        print("DEBUG-TextVC: keyboard showing..")
                        UIView.animate(withDuration: 0.5) {
                            self.view.layoutIfNeeded()
                        } completion: { complete in
                            scroll = true
                            self.collectionView.scrollToItem(at: [0, self.messagesChat.count - 1], at: .bottom, animated: true)
                        }
                    }
                    scroll = true
                case .keyboardWillHide:
                    print("DEBUG-TextVC: keyboard hiding..")
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded()
                    } completion: { complete in
                        scroll = false
                    }
                }
        }
    }
    
    
}

//MARK: - Datasource

extension TextViewController {
    
    //this is "number of item (not ROW) in section", so it will line up horizontally
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesChat.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.messageCell = messagesChat[indexPath.row]
        cell.messageCell?.user = textingUser
        return cell
    }
}

//MARK: - Delegate
extension TextViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG-TextVC: tap on collectionView")
        customInputView.messageInputTextView.endEditing(true)
    }
    
}


//MARK: - FlowLayout Protocol
//this Protocol set the size, frame, and location for message bubble

extension TextViewController: UICollectionViewDelegateFlowLayout {
    
    //all messages bubbles are in a stackView, this func sets anchor for that stackView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    //let's get the message bubble line up vertically, also set the width and height for each cell that holds (meaasage bubble + profileImage)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //set messages to NOT overlap when it gets long. If you want to specify the exact height for each message bubble, then the line above is good enough
        let frameCollectionView = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimateSizeCell = MessageCell(frame: frameCollectionView)
        estimateSizeCell.messageCell = messagesChat[indexPath.row]
        estimateSizeCell.layoutIfNeeded() //this func gets called if the height of the message bubble is larger than 50 (specified in frameCollectionView above)
        
        let targetSize = CGSize(width: view.frame.width, height: 1000) //if the message bubble is higher than 50, then we set the max height to 1000 pts
        let estimateSize = estimateSizeCell.systemLayoutSizeFitting(targetSize) //this func sets the appropriate height for the cell in 2 cases:  smaller than 40 or in between 40 and 1000 pts
        
        return .init(width: view.frame.width, height: estimateSize.height)
    }
    
}

//MARK: - Protocol from ChatTextBox
//remember to write ".delegate = self"
extension TextViewController: ChatTextBoxDelegate {
    func takeAPict() {
        print("DEBUG-TextVC: now take a pict")
        
    }
    
    func sendAPict() {
        print("DEBUG-TextVC: now show the library")
        
    }
    
    func inputView(wantsToSend text: String) {
        print("DEBUG-TextVC: send btn hit, - \"\(text)\"")
        sendMessage(txt: text)
    }
    
}
