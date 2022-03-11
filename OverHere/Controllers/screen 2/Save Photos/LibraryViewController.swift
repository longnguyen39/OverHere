//
//  SavedPhotosViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 1/10/22.
//

import UIKit

private let reuseID = "reuseIdentifier"

class LibraryViewController: UIViewController {
    
    var bigPhotoArray = [Picture]() 
    var phoneCurrent: String = "" //filled in CameraVC
    
//MARK: - Components
    
    private let tableView = UITableView()
    
    private let noImageLabel: UILabel = {
        let lb = UILabel()
        lb.text = "No Image to show."
        lb.textColor = .gray
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        return lb
    }()
    
    //let's deal with the SearchBar
    private let searchBarController = UISearchController(searchResultsController: nil)
    private var filteredPhotos = [Picture]()
    
    //this is dynamics (change its value all the time base on searchBar's behavior)
    private var isSearchMode: Bool {
        return searchBarController.isActive && !searchBarController.searchBar.text!.isEmpty
        //returns true only if searchBar is active and searchText is NOT empty
    }
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSearchBarController()
        fetchPhotoInfo()
        
    }
    
    private func configureUI() {
        let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
        configureNavigationBar(title: "Library", preferLargeTitle: false, backgroundColor: navColor, buttonColor: .green, interface: .dark)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissVC))
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        //for default cell, use  "UITableViewCell.self"
        tableView.register(PictureCell.self, forCellReuseIdentifier: reuseID)
        tableView.rowHeight = 100 //88
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
    }
    
    private func configureSearchBarController() {
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.hidesNavigationBarDuringPresentation = true
        searchBarController.searchBar.placeholder = "Search name or date"
        searchBarController.searchBar.barStyle = UIBarStyle.black
        navigationItem.searchController = searchBarController //got affect by the UIInterfaceStyle of the navBar
        definesPresentationContext = false
        
        searchBarController.searchBar.delegate = self
        searchBarController.searchResultsUpdater = self
    }
    
//MARK: - Actions
      
    private func showNoImage() {
        self.noImageLabel.isHidden = self.bigPhotoArray.count != 0
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchPhotoInfo() {
        showLoadingView(true, message: "Loading...")
        print("DEBUG-LibraryVC: fetching images...")
        
        FetchingStuff.fetchPhotos(phone: phoneCurrent) { pictureArray in
            self.bigPhotoArray = pictureArray
            self.showNoImage()
            self.showLoadingView(false, message: "Loading...")
            self.tableView.reloadData()
        }
    }

}

//MARK: - SearchBar Delegate
//this extension declares what happen when clicks on the searchBar or "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension LibraryViewController: UISearchBarDelegate {
    
    //this is what happens when searchBar is clicked
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("DEBUG-LibraryVC: SearchBar is active")
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
extension LibraryViewController: UISearchResultsUpdating {
    
    //this gets called when we hit the searchBar and whenever type in the search textBox
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchBarController.searchBar.text?.lowercased() else { return }
        print("DEBUG-LibraryVC: searchText is \(searchText)")
        //Set the filteredPhotos
        self.filteredPhotos = bigPhotoArray.filter({
            $0.title.lowercased().contains(searchText) || $0.date.lowercased().contains(searchText)
        }) //keep in mind, this shit is CASE SENSITIVE, so we convert all to lowercased
        
        tableView.alpha = filteredPhotos.count > 0 ? 1 : 0.37
        
        print("DEBUG-UserVC: we have \(filteredPhotos.count) filtered photos")
        self.tableView.reloadData()
    }
    
}

//MARK: - tableView Datasource

extension LibraryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filteredPhotos.count : bigPhotoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! PictureCell
        cell.photoInfo = isSearchMode ? filteredPhotos[indexPath.row] : bigPhotoArray[indexPath.row]
        
        return cell
    }
    
}

//MARK: - tableView Delegate
extension LibraryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //unhightlight the cell tapped
        
        let vc = MapPhotoViewController()
        vc.photoLocationInfo = isSearchMode ? filteredPhotos[indexPath.row] : bigPhotoArray[indexPath.row]
//        vc.currentEmail = userMail

        navigationController?.pushViewController(vc, animated: true)
    }
    
}
