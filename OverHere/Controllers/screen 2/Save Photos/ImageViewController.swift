//
//  ImageViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 1/29/22.
//

import UIKit
import SDWebImage

class ImageViewController: UIViewController {

    private let btnDimension: CGFloat = 32
    var photoInfo: Picture?
    
    private var imageURL: URL? {
        return URL(string: photoInfo?.imageUrl ?? "no url")
    }
    
//MARK: - Components
    
    private let scrollView = UIScrollView()
    
    private let topCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private var imageBig: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        return iv
    }()
    
    private let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(dismissPhoto), for: .touchUpInside)
        
        return btn
    }()
    
    //bottom components
    
    private let bottomCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let bottomView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(sendTo), for: .touchUpInside)
        
        return btn
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(sharePhoto), for: .touchUpInside)
        
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - View Scenes
    
    init(imageInfo: Picture) {
        super.init(nibName: nil, bundle: nil)
        self.photoInfo = imageInfo
        imageBig.sd_setImage(with: imageURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        scrollViewZoom()
        swipeGesture()
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private func configureUI() {
        
        view.addSubview(topCover)
        topCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor)
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.addSubview(imageBig)
        imageBig.frame = scrollView.bounds
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8, width: btnDimension, height: btnDimension)
        
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
        
        view.addSubview(bottomCover)
        bottomCover.anchor(top: bottomView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        //bottom buttons
        let stack = UIStackView(arrangedSubviews: [shareButton, saveButton, sendButton])
        shareButton.setDimensions(height: btnDimension, width: btnDimension)
        sendButton.setDimensions(height: btnDimension, width: btnDimension)
        saveButton.setDimensions(height: btnDimension, width: btnDimension)
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        bottomView.addSubview(stack)
        stack.anchor(top: bottomView.topAnchor, left: bottomView.leftAnchor, bottom: bottomView.bottomAnchor, right: bottomView.rightAnchor, paddingLeft: 12, paddingRight: 12)
    }
    
//MARK: - Actions
    
    @objc func sendTo() {
        
    }
   
    @objc func sharePhoto() {
        guard let imgShare = imageBig.image else { return }
        let shareText = "Share Image"
        
        let vc = UIActivityViewController(activityItems: [shareText, imgShare], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func savePhoto() {
        guard let imageToSave = imageBig.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil) //this will require access to photo library, so gotta check auth status
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }

    }
    
    @objc func dismissPhoto() {
        dismiss(animated: true, completion: nil)
    }
    
    private func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissPhoto))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func scrollViewZoom() { //this func needs extension UIScrollViewDelegate
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
    }
    
}

//MARK: - scrollView to zoom
//remember to write "scrollView.delegate = self" in viewDidLoad
extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageBig
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageBig.image {
                let ratioW = imageBig.frame.width / image.size.width
                let ratioH = imageBig.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = newWidth*scrollView.zoomScale > imageBig.frame.width
                let leftAn = 0.5 * (conditionLeft ? (newWidth - imageBig.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = newHeight*scrollView.zoomScale > imageBig.frame.height
                let topAn = 0.5 * (conditionTop ? (newHeight - imageBig.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: topAn, left: leftAn, bottom: topAn, right: leftAn)
            }
        } else {
            scrollView.contentInset = .zero
        }
        
    }
    
}
