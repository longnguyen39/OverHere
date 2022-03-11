//
//  ScrollViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/17/21.
//

import UIKit
import Firebase

protocol ScrollViewControllerDelegate: AnyObject {
    func fetchInfoWhenLogin()
}

//this VC has 3 pages: SettingVC, CameraVC and ChatVC
class ScrollViewController: UIViewController {
    
    weak var delegate: ScrollViewControllerDelegate?
    
    let currentPhone = Auth.auth().currentUser?.phoneNumber
    let greenTabItem: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    private let navColor = #colorLiteral(red: 0.09455803782, green: 0.09577188641, blue: 0.09572397918, alpha: 1) //black without full opacity
    private var user = User(dictionary: [:])
    var phoneNo = Auth.auth().currentUser?.phoneNumber ?? "nil"
    
    private let alphaBottomCamera: CGFloat = 0.67
    
    private var logOutObserver: NSObjectProtocol?
    private var checkUsernameObserver: NSObjectProtocol?
    private var scrollEnable: NSObjectProtocol?
    private var scrollDisable: NSObjectProtocol?
    
//MARK: - Components
    
    private let loadingLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        lb.text = ""
        lb.textColor = .white
        lb.textAlignment = .center
        
        return lb
    }()
    
    let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
//        scrollView.backgroundColor = .red
        
        return scrollView
    }()
    
    private var segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["", "", ""])
        sc.backgroundColor = .black
        
        //set the text color for the text of the sc (no need in this app)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        sc.selectedSegmentIndex = 1
        sc.selectedSegmentTintColor = UIColor.green
        
        return sc
    }()
    
    private let bottomView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let bottomCoverView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let cameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
        btn.tintColor = .green
        btn.addTarget(self, action: #selector(switchToCameraVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let cameraTitle: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.text = "Camera"
        lb.textColor = .green
        lb.textAlignment = .center
        lb.isUserInteractionEnabled = true
        
        return lb
    }()
    
    private let chatBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "message"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(switchToChatVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let chatTitle: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.text = "Chat"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.isUserInteractionEnabled = true
        
        return lb
    }()
    
    private let mapBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(switchToMapVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let mapTitle: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.text = "Map"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.isUserInteractionEnabled = true
        
        return lb
    }()
    
    let mapVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    let cameraVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    let chatVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(loadingLabel)
        loadingLabel.centerX(inView: view)
        loadingLabel.centerY(inView: view)
        horizontalScrollView.isScrollEnabled = true
        
        checkAuth()
        protocolVC()
        
        configureHoriScrollView()
        configureBottomView()
        configureAllVC()
        
    }
    
    //gotta configure the bottom buttons here after the "bottomCover.frame.height" is set
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bottomCover = bottomCoverView.frame.height
        configureBottomButton(viewCover: bottomCover)
        configureBottomTitle()
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private func configureHoriScrollView() {
        view.addSubview(horizontalScrollView)
        horizontalScrollView.frame = view.bounds //fill entire screen
        
        horizontalScrollView.contentSize = CGSize(width: view.frame.width*3, height: view.frame.height)
        horizontalScrollView.contentInsetAdjustmentBehavior = .never //hide the nav bar above when launched
        horizontalScrollView.contentOffset = CGPoint(x: view.frame.width, y: 0)
        horizontalScrollView.delegate = self //for Extension ScrollView Delegate and protocol below
    }
    
    private func configureBottomView() {
        
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 44)
        bottomView.alpha = alphaBottomCamera
        
        view.addSubview(bottomCoverView)
        bottomCoverView.anchor(top: bottomView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        bottomCoverView.alpha = alphaBottomCamera
        
        view.addSubview(segment)
        segment.anchor(top: bottomView.topAnchor, left: bottomView.leftAnchor, right: bottomView.rightAnchor, height: 2)
        segment.addTarget(self, action: #selector(segmentSwitch), for: .valueChanged)
        
    }
    
    private func configureBottomButton(viewCover: CGFloat) {
        let smallView = view.frame.width/3
        
        view.addSubview(mapBtn)
        mapBtn.frame = CGRect(
            x: (smallView-30)/2,
            y: view.frame.height-viewCover-44+2+6,
            width: 30, height: 26)
        
        view.addSubview(cameraBtn)
        cameraBtn.frame = CGRect(
            x: smallView + (smallView-32)/2,
            y: view.frame.height-viewCover-44+2+6,
            width: 32, height: 26)
        
        view.addSubview(chatBtn)
        chatBtn.frame = CGRect(
            x: 2*smallView + (smallView-30)/2,
            y: view.frame.height-viewCover-44+2+6,
            width: 30, height: 26)
    }
    
    private func configureBottomTitle() {
        view.addSubview(mapTitle)
        mapTitle.anchor(top: mapBtn.bottomAnchor, paddingTop: 4)
        mapTitle.centerX(inView: mapBtn)
        
        view.addSubview(cameraTitle)
        cameraTitle.anchor(top: cameraBtn.bottomAnchor, paddingTop: 4)
        cameraTitle.centerX(inView: cameraBtn)
        
        view.addSubview(chatTitle)
        chatTitle.anchor(top: chatBtn.bottomAnchor, paddingTop: 4)
        chatTitle.centerX(inView: chatBtn)
        
        titleTap()
    }
    

//MARK: - Protocols
    
    func protocolVC() {
        
        //protocol from SettingVC
        logOutObserver = NotificationCenter.default.addObserver(forName: .didLogOut, object: nil, queue: .main) { [weak self] _ in

            print("DEBUG-ScrollVC: logged out update notified, presenting LoginVC..")
            guard let strongSelf = self else { return }
            strongSelf.logOut()
        }

        //protocol from UsernamVC or CodeVC
        checkUsernameObserver = NotificationCenter.default.addObserver(forName: .checkUsername, object: nil, queue: .main) { [weak self] _ in

            print("DEBUG-ScrollVC: login update notified, checking username..")
            guard let strongSelf = self else { return }
            strongSelf.checkUsername()
        }

        //protocol from ChatVC
//        scrollEnable = NotificationCenter.default.addObserver(forName: .enableScroll, object: nil, queue: .main) { [weak self] _ in
//
//            print("DEBUG-ScrollVC: scroll enabling notified..")
//            guard let strongSelf = self else { return }
//            strongSelf.horizontalScrollView.isScrollEnabled = true
//        }

        //protocol from ChatVC
//        scrollDisable = NotificationCenter.default.addObserver(forName: .disableScroll, object: nil, queue: .main) { [weak self] _ in
//
//            print("DEBUG-ScrollVC: scroll disabling notified..")
//            guard let strongSelf = self else { return }
//            strongSelf.horizontalScrollView.isScrollEnabled = false
//        }

    }

    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = logOutObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        if let observer2 = checkUsernameObserver {
            NotificationCenter.default.removeObserver(observer2)
        }
//        if let observer3 = scrollDisable {
//            NotificationCenter.default.removeObserver(observer3)
//        }
//        if let observer4 = scrollEnable {
//            NotificationCenter.default.removeObserver(observer4)
//        }

    }
    
//MARK: - Actions
    
    private func titleTap() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(switchToMapVC))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(switchToCameraVC))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(switchToChatVC))
        mapTitle.addGestureRecognizer(tap1)
        cameraTitle.addGestureRecognizer(tap2)
        chatTitle.addGestureRecognizer(tap3)
    }
    
    private func hideOrShowBottomViews(alpha: CGFloat) {
        bottomView.alpha = alpha
        bottomCoverView.alpha = alpha
        segment.alpha = alpha
        mapBtn.alpha = alpha
        cameraBtn.alpha = alpha
        chatBtn.alpha = alpha
    }
    
    private func setUpTabButton(tintChat: UIColor, tintCam: UIColor, tintSetting: UIColor, index: Int, bottomVColor: UIColor) {
        chatBtn.tintColor = tintChat
        chatTitle.textColor = tintChat
        cameraBtn.tintColor = tintCam
        cameraTitle.textColor = tintCam
        mapBtn.tintColor = tintSetting
        mapTitle.textColor = tintSetting
        segment.selectedSegmentIndex = index
        bottomView.backgroundColor = bottomVColor
        bottomCoverView.backgroundColor = bottomVColor
    }
    
    @objc func switchToChatVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: 2*view.frame.width, y: 0), animated: false)
        chatBtn.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    }
    
    @objc func switchToCameraVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: false)
    }
    
    @objc func switchToMapVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @objc func segmentSwitch() {
        if segment.selectedSegmentIndex == 0 {
            switchToMapVC()
        } else if segment.selectedSegmentIndex == 1 {
            switchToCameraVC()
        } else {
            switchToChatVC()
        }
    }
    
//MARK: - Auth stuff
    
    private func presentLoginVC() {
        DispatchQueue.main.async {
            print("DEBUG-ScrollVC: showing auth..")
            let vc = PhoneNumberViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func checkAuth() {
        if currentPhone == nil || currentPhone == "nil" {
            print("DEBUG-ScrollVC: no user logged in")
            presentLoginVC()
        } else {
            guard let phoneNo = currentPhone else { return }
            print("DEBUG-ScrollVC: \(phoneNo) is currently logged in")
            checkUsername()
        }
    }
    
    private func checkUsername() {
        showLoadingView(true)
        if phoneNo == "nil" {
            if let phone = userDefault.shared.defaults.value(forKey: "currentPhone") as? String {
                phoneNo = phone
            } else {
                print("DEBUG-SettingVC: no phone number available")
            }
        }
        
        UserService.fetchUserInfo(phoneFull: phoneNo) { infoFetched in
            self.user = infoFetched
            self.showLoadingView(false)
            if self.user.username == "username..." {
                print("DEBUG-ScrollVC: need to change username")
                self.presentUsernameVC()
            } else {
                print("DEBUG-ScrollVC: Hi, \(self.user.username), setting up..")
                NotificationCenter.default.post(name: .didLogIn, object: nil) //declared in 3 main VCs
            }
        }
    }
    
    private func presentUsernameVC() {
        DispatchQueue.main.async {
            print("DEBUG-ScrollVC: showing UsernameVC..")
            let vc = UsernameViewController()
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func logOut() {
        showLoadingView(true)
        let userPhone = Auth.auth().currentUser?.phoneNumber ?? "nil"
        do {
            try Auth.auth().signOut()
            self.showLoadingView(false)
            self.presentLoginVC()
            print("DEBUG-Authentication: done signing out \(userPhone)")
        } catch  {
            print("DEBUG: error signing out \(userPhone)")
            self.alert(error: "Error signing out.", buttonNote: "Try again")
        }
    }
    
//    private func fetchCurrentUserInfo(completion: @escaping(Bool) -> Void) {
//        guard let phoneUser = currentPhone else { return }
//        var fetch = false
//        UserService.fetchUserInfo(phoneFull: phoneUser) { userInfo in
//            print("DEBUG-ScrollVC: fetching userInfo..")
//            self.user = userInfo
//            fetch = true
//            completion(fetch)
//        }
//    }
    
//MARK: - SetUp some VCs
    
    private func setUpMapVC() {
        let vc = MapViewController()
//        let nav = UINavigationController(rootViewController: vc)
        mapVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        
        horizontalScrollView.addSubview(mapVC.view)
        mapVC.view.frame = CGRect(x: 0, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(mapVC) //add mapVC as a child to ScrollVC
        mapVC.didMove(toParent: self)
    }
    
    private func setUpCameraVC() {
        let vc = CameraViewController()
        cameraVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)

        horizontalScrollView.addSubview(cameraVC.view)
        cameraVC.view.frame = CGRect(x: view.frame.width, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(cameraVC) //add cameraVC as a child to ScrollVC
        cameraVC.didMove(toParent: self)
    }
    
    private func setUpChatVC() {
        let vc = ChatViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        chatVC.setViewControllers([nav], direction: .forward, animated: false, completion: nil)
        
        horizontalScrollView.addSubview(chatVC.view)
        chatVC.view.frame = CGRect(x: 2*view.frame.width, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(chatVC) //add chatVC as a child to ScrollVC
        chatVC.didMove(toParent: self)
    }
    
    private func configureAllVC() {
        setUpCameraVC()
        setUpMapVC()
        setUpChatVC()
    }

}

//MARK: - Extension ScrollView Delegate
//remember to write ".delegate = self" in ViewDidLoad
extension ScrollViewController: UIScrollViewDelegate {

    //this gets called whenever we touch or scroll the scrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xCoor = scrollView.contentOffset.x
        
        if xCoor == 0 || xCoor < view.frame.width/2 {
            setUpTabButton(tintChat: .white, tintCam: .white, tintSetting: greenTabItem, index: 0, bottomVColor: navColor)

        } else if xCoor > (view.frame.width/2) && xCoor < (3*view.frame.width/2) {
            let btmClr = UIColor.black.withAlphaComponent(alphaBottomCamera)
            setUpTabButton(tintChat: .white, tintCam: greenTabItem, tintSetting: .white, index: 1, bottomVColor: btmClr)
            
        } else if xCoor > (3*view.frame.width/2) {
            setUpTabButton(tintChat: greenTabItem, tintCam: .white, tintSetting: .white, index: 2, bottomVColor: navColor)
        }
        
    }
    

}

//MARK: - Protocol from ChatVC
//remember to write ".delegate = self" in ViewDidLoad
extension ScrollViewController: ChatViewControllerDelegate {
    func disableScroll() {
        print("DEBUG-ScrollVC: protocol from ChatVC, disable scroll")
        horizontalScrollView.isScrollEnabled = false
    }

    func enableScroll() {
        print("DEBUG-ScrollVC: protocol from ChatVC, enable scroll")
        horizontalScrollView.isScrollEnabled = true
    }
    
}

//MARK: - Protocol from MapVC
//remember to write ".delegate = self" in ViewDidLoad

//extension ScrollViewController: MapViewControllerDelegate {
//    func showBottomMap() {
//        UIView.animate(withDuration: 0.2) {
//            self.hideOrShowBottomViews(alpha: 0)
//        }
//    }
//
//    func showBottomBar() {
//        UIView.animate(withDuration: 0.2) {
//            self.hideOrShowBottomViews(alpha: 1)
//        }
//    }
//
//
//}

