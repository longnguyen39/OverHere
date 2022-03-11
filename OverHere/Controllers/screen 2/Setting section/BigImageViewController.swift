//
//  BigImageViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 10/24/21.
//

import UIKit
import SDWebImage

class BigImageViewController: UIViewController {
    
    var userInfo = User(dictionary: [:])
    
    private var profileURL: URL? {
        return URL(string: userInfo.profileImageUrl)
    }
    
//MARK: - Components
    
    private let scrollView = UIScrollView()
    
    private let dismissBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        
        return iv
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
        
        configureUI()
        displayImg()
        scrollViewZoom()
        swipeGesture()
    }
    
//MARK: - Configuration
    
    private func configureUI() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.addSubview(profileImageView)
        profileImageView.frame = scrollView.bounds
        
        view.addSubview(dismissBtn)
        dismissBtn.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 12, width: 24, height: 24)
    }
    
    private func scrollViewZoom() { //this func needs extension UIScrollViewDelegate
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
    }
    
//MARK: - Actions
    
    private func displayImg() {
        if userInfo.profileImageUrl == "none" {
            userNameLetterIV(userName: userInfo.username) { iv in
                self.profileImageView.image = iv.image
                self.profileImageView.tintColor = iv.tintColor
            }
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    private func swipeGesture() {
        let down = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        down.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(down)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
   

}

//MARK: - scrollView to zoom
//remember to write "scrollView.delegate = self" in viewDidLoad
extension BigImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return profileImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = profileImageView.image {
                let ratioW = profileImageView.frame.width / image.size.width
                let ratioH = profileImageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = newWidth*scrollView.zoomScale > profileImageView.frame.width
                let leftAn = 0.5 * (conditionLeft ? (newWidth - profileImageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = newHeight*scrollView.zoomScale > profileImageView.frame.height
                let topAn = 0.5 * (conditionTop ? (newHeight - profileImageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: topAn, left: leftAn, bottom: topAn, right: leftAn)
            }
        } else {
            scrollView.contentInset = .zero
        }
        
    }
    
}
