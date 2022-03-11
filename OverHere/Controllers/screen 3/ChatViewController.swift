//
//  ChatViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/18/21.
//

import UIKit
import Firebase

private let cellIndentifier = "cellIndentifier"

protocol ChatViewControllerDelegate: AnyObject {
    func disableScroll()
    func enableScroll()
}

class ChatViewController: UIViewController {
    
    weak var delegate: ChatViewControllerDelegate?
    private var logInObserver: NSObjectProtocol?
    
    var currentUser = User(dictionary: [:])
    private var phoneCurrent = Auth.auth().currentUser?.phoneNumber ?? "nil"
    private var updateRepeat = true
    
    private var converList = [Conversation]() {
        didSet {
            noTextImageView.isHidden = converList.count != 0
            noTextlabel.isHidden = converList.count != 0
            if updateRepeat {
                fetchUpdateConver()
            }
        }
    }
    private var friends = [User]()
    
    private let tableView = UITableView()
    let cellHeight: CGFloat = 80
    
    private var conversationDictionary = [String: Conversation]() //this is to fix the "duplicating message" bug
    
//MARK: - Components
    
    private let topSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let noTextImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "captions.bubble")
        iv.tintColor = .green.withAlphaComponent(0.87)
        iv.backgroundColor = .clear
        iv.setDimensions(height: 120, width: 120)
        
        return iv
    }()
    
    private let noTextlabel: UILabel = {
        let lb = UILabel()
        lb.text = "No conversations yet"
        lb.textColor = .lightGray
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        
        return lb
    }()
    
    //let's deal with the SearchBar
    private let searchBarController = UISearchController(searchResultsController: nil)
    private var filteredConver = [Conversation]()
    private var filteredFriends = [User]()
    
    //this is dynamics (change its value all the time base on searchBar's behavior)
    private var isSearchMode: Bool {
        return searchBarController.isActive && !searchBarController.searchBar.text!.isEmpty
        //returns true only if searchBar is active and searchText is NOT empty
    }
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureSearchBarController()
        configureTableView()
        protocolVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.disableScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        delegate?.enableScroll()
    }
    
//MARK: - Protocols
    
    func protocolVC() {
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogIn, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-ChatVC: login notified, fetching ChatVC..")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserInfo { canFetchUserInfo in
                if canFetchUserInfo {
                    strongSelf.fetchConversations()
                } else {
                    print("DEBUG-ChatVC: userInfo is empty")
                }
            }
        }
    }
    
    deinit {
        if let observer = logInObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
//MARK: - Configuration
    
    private func configureNavBar() {
        let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: "Chats", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark) //the "interface" can affect tintColor of SearchBar
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editNavBar))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(newChatNavBar))
    }
    
    private func configureSearchBarController() {
        searchBarController.obscuresBackgroundDuringPresentation = true
        searchBarController.hidesNavigationBarDuringPresentation = true
        searchBarController.searchBar.placeholder = "Search.."
        searchBarController.searchBar.barStyle = UIBarStyle.black
        navigationItem.searchController = searchBarController //got affect by the UIInterfaceStyle of the navBar
        definesPresentationContext = false
        
        searchBarController.searchBar.delegate = self
        searchBarController.searchResultsUpdater = self
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .black
        tableView.register(ConversationCell.self, forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = cellHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(topSeparator) //to create a space with the header
        topSeparator.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 0.02)
        
        view.addSubview(tableView)
        tableView.anchor(top: topSeparator.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 44) //44 is height of tab bar
        
        //now in case there is no conversation
        view.addSubview(noTextImageView)
        noTextImageView.anchor(top: topSeparator.bottomAnchor, paddingTop: 32)
        noTextImageView.centerX(inView: view)
        
        view.addSubview(noTextlabel)
        noTextlabel.anchor(top: noTextImageView.bottomAnchor, paddingTop: 8)
        noTextlabel.centerX(inView: noTextImageView)
    }
    
//MARK: - Actions
    
    private func fetchUserInfo(completion: @escaping(Bool) -> Void) {
        if phoneCurrent == "nil" {
            if let phone = userDefault.shared.defaults.value(forKey: "currentPhone") as? String {
                print("DEBUG-CameraVC: got phoneNo from userDefault")
                phoneCurrent = phone
            } else {
                print("DEBUG-SettingVC: no phone number available")
            }
        }
        UserService.fetchUserInfo(phoneFull: phoneCurrent) { userInfo in
            print("DEBUG-SettingVC: fetching userInfo..")
            self.currentUser = userInfo
            if self.currentUser.phone == "" {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func fetchConversations() {
        FetchingStuff.fetchConver(currentUser: currentUser) { converArr in
            converArr.forEach { conver in
                let phoneConver = conver.phoneNo
                self.conversationDictionary[phoneConver] = conver
            }
            self.converList = Array(self.conversationDictionary.values) //let's fill up the array
            print("DEBUG-ChatVC: we have \(self.converList.count) conver")
            self.tableView.reloadData()
        }
       
    }
    
    private func fetchUpdateConver() {
        FetchingStuff.fetchAllFriends(currentPh: self.currentUser.phone) { friendArr in
            self.friends = friendArr
        }
        FetchingStuff.fetchUpdateConver(currentPh: self.currentUser.phone) { conArr in
            self.converList = conArr
            self.tableView.reloadData()
            self.updateRepeat = !self.updateRepeat
        }
    }
    
    @objc func editNavBar() {
        
    }
    
    @objc func newChatNavBar() {
        DispatchQueue.main.async {
            let vc = UsersViewController(nowUser: self.currentUser)
            vc.delegate = self //make protocol works
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func moveCell(from: IndexPath, to: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: {
                self.tableView.moveRow(at: from, to: to)
            }) { (true) in
                // write here code to remove score from array at position "at" and insert at position "to" and after reloadData()
            }
        }
    
}

//MARK: - SearchBar Delegate
//this extension declares what happen when clicks on the searchBar or "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension ChatViewController: UISearchBarDelegate {
    
    //this is what happens when searchBar is clicked
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("DEBUG-ChatVC: SearchBar is active")
    }

    //what happens when cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.tableView.alpha = 1
            }
        }
        searchBar.endEditing(true) //dismiss the keyboard
        searchBar.showsCancelButton = false
        searchBar.text = ""
    }
    
}

//MARK: - SearchBar Result update
//remember to write "searchBarController.searchResultsUpdater = self"
extension ChatViewController: UISearchResultsUpdating {
    
    //this func gets called when we hit the searchBar and whenever we type something in the search textBox
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchBarController.searchBar.text?.lowercased() else { return }
        print("DEBUG-ChatVC: searchText is \(searchText)")
        //Set the filteredPhotos
        self.filteredFriends = friends.filter({
            $0.phone.contains(searchText) || $0.username.lowercased().contains(searchText)
        })
        self.filteredConver = converList.filter({
            $0.phoneNo.contains(searchText) || $0.username.lowercased().contains(searchText)
        }) //this is CASE SENSITIVE, so we convert both the searchText to lowercased
        
        tableView.alpha = filteredConver.count > 0 ? 1 : 0.37
                
        print("DEBUG-ChatVC: we have \(filteredConver.count) filtered photos")
        self.tableView.reloadData()
    }
    
}

//MARK: - tableView Datasource
//remember to write ".datasource = self" in ViewDidLoad
extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filteredConver.count : converList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! ConversationCell
        cell.conversations = isSearchMode ? filteredConver[indexPath.row] : converList[indexPath.row]
        cell.delegate = self //make the protocol works
        cell.index = indexPath.row
        
        return cell
    }
    
    //this func helps us to move the cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

//MARK: - tableView Delegate
//remember to write ".datasource = self" in ViewDidLoad
extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let friend = isSearchMode ? filteredFriends[indexPath.row] : friends[indexPath.row]
        let vc = TextViewController(otherUser: friend, me: currentUser, didTap: true, index: indexPath.row)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Protocol from UsersVC
//remember to write ".delegate = self" in ViewDidLoad
extension ChatViewController: UsersViewControllerDelegate {
    func showNavAndTable() {
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.alpha = 1
            self.tableView.alpha = 1
        }
    }
    
    func hideNavAndTable() {
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.alpha = 0
            self.tableView.alpha = 0
        }
    }
    
}

//MARK: - Protocol from ConversationCell
//remember to write ".delegate = self" in ViewDidLoad
extension ChatViewController: ConversationCellDelegate {
    func arrangeConver(idx: Int) {
//        print("DEBUG-ChatVC: we got 'New chats', now refetch")
//        let fromIdxPath = IndexPath(row: 1, section: 0)
//        let toIdxPath = IndexPath(row: 0, section: 0)
//        moveCell(from: fromIdxPath, to: toIdxPath)
    }
    
}

//MARK: - Protocol from TextVC
//remember to write ".delegate = self" in ViewDidLoad
extension ChatViewController: TextViewControllerDelegate {
    
    func moveSentToTop(idx: Int) {
//        print("DEBUG-ChatVC: we got 'Sent', now refetch")
//        let fromIdxPath = IndexPath(row: idx, section: 0)
//        let toIdxPath = IndexPath(row: 0, section: 0)
//        moveCell(from: fromIdxPath, to: toIdxPath)
    }
    
}

//MARK: - Protocol from ScrollVC
//remember to write ".delegate = self" in ViewDidLoad
extension ChatViewController: ScrollViewControllerDelegate {
    func fetchInfoWhenLogin() {
        fetchConversations()
    }
    
}

