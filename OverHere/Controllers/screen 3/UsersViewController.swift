//
//  UsersViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 10/23/21.
//

import UIKit

private let userIndentifier = "userIndentifier"

protocol UsersViewControllerDelegate: AnyObject {
    func showNavAndTable()
    func hideNavAndTable()
}

class UsersViewController: UIViewController {
    
    weak var delegate: UsersViewControllerDelegate?
    private var userList = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
//MARK: - Components
    
    private var currentUser = User(dictionary: [:])
    private let tableView = UITableView()
    let cellHeight: CGFloat = 80
    
    var profImgArray = [UIImage]()
    
    private let topSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    //SearchBar
    private let searchBarController = UISearchController(searchResultsController: nil)
    private var filteredUsers = [User]()
    
    //this frequently changes value depending on the searchBar's behavior
    private var isSearchMode: Bool {
        return searchBarController.isActive && !searchBarController.searchBar.text!.isEmpty
        //returns true only if searchBar is active and searchText is NOT empty
    }
    
//MARK: - View Scenes

    init(nowUser: User) {
        self.currentUser = nowUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delegate?.hideNavAndTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureSearchBarController()
        configureTableView()
        fetchUsers()
    }
    
    
//MARK: - Configutation
    
    private func configureNavBar() {
        let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: "New Chats", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark) //the "interface" can affect tintColor of SearchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(dismissVC))
    }
    
    private func configureSearchBarController() {
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.hidesNavigationBarDuringPresentation = true
        searchBarController.searchBar.placeholder = "Search for phone or username"
        searchBarController.searchBar.barStyle = UIBarStyle.black
        navigationItem.searchController = searchBarController //got affect by the UIInterfaceStyle of the navBar
        definesPresentationContext = false
        
        searchBarController.searchBar.delegate = self
        searchBarController.searchResultsUpdater = self
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .black
        tableView.register(UserCell.self, forCellReuseIdentifier: userIndentifier)
        tableView.rowHeight = cellHeight
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(topSeparator)
        topSeparator.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 0.02)
        
        view.addSubview(tableView)
        tableView.anchor(top: topSeparator.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
   
    
//MARK: - Actions
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
        delegate?.showNavAndTable()
    }
    
    private func fetchUsers() {
        showLoadingView(true)
        FetchingStuff.fetchAllUsers { userArray in
            self.userList = userArray
            self.moveCurrentUserOnTop()
            self.showLoadingView(false)
        }
    }
    
    private func moveCurrentUserOnTop() {
        var indexCurrent = 0
        for idx in 0...userList.count-1 {
            if userList[idx].phone == currentUser.phone {
                indexCurrent = idx
            }
        }
        let itemToMove = userList[indexCurrent]
        userList.remove(at: indexCurrent)
        userList.insert(itemToMove, at: 0) //move to front of array
    }

}

//MARK: - SearchBar Delegate
//this extension declares what happen when clicks on the searchBar or "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension UsersViewController: UISearchBarDelegate {
    
    //this is what happens when searchBar is clicked
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("DEBUG-UserVC: SearchBar is active")
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
extension UsersViewController: UISearchResultsUpdating {
    
    //this func gets called when we hit the searchBar and whenever we type something in the search textBox
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchBarController.searchBar.text?.lowercased() else { return }
        print("DEBUG-UserVC: searchText is \(searchText)")
        //Set the filteredPhotos
        self.filteredUsers = userList.filter({
            $0.phone.contains(searchText) || $0.username.lowercased().contains(searchText)
        }) //keep in mind, this shit is CASE SENSITIVE, so we convert both the searchText and "phone, username,..." to lowercased
        
        tableView.alpha = filteredUsers.count > 0 ? 1 : 0.37
                
        print("DEBUG-UserVC: we have \(filteredUsers.count) filtered users")
        self.tableView.reloadData()
    }
    
}

//MARK: - tableView Datasource
//remember to write ".datasource = self" in ViewDidLoad
extension UsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let NoOfUsers = 10
        if isSearchMode { //whenever user type something in
            return filteredUsers.count > NoOfUsers ? NoOfUsers : filteredUsers.count
        } else {
            return userList.count > NoOfUsers ? NoOfUsers : userList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userIndentifier, for: indexPath) as! UserCell
        cell.userInfo = isSearchMode ? filteredUsers[indexPath.row] : userList[indexPath.row]
        cell.currentUserInfo = currentUser
        
        return cell
    }
    
}

//MARK: - tableView Delegate
//remember to write ".datasource = self" in ViewDidLoad
extension UsersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("DEBUG-UsersVC: row \(indexPath.row) tapped")
        let newTextUser = isSearchMode ? filteredUsers[indexPath.row] : userList[indexPath.row]
        let vc = TextViewController(otherUser: newTextUser, me: currentUser, didTap: true, index: -1)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Protocol from
//remember to write ".delegate = self"
