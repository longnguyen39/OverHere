//
//  CameraViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 9/18/21.
//

import UIKit
import Firebase
import AVFoundation //needed for building customizable camera
import MapKit //to get user current location

class CameraViewController: UIViewController {
    
    private var didCheckCameraPermission = false
    private var logInObserver: NSObjectProtocol?
    private var runCamObserver: NSObjectProtocol?
    private var phoneUser = Auth.auth().currentUser?.phoneNumber ?? "nil"
    var currentUser = User(dictionary: [:]) {
        didSet {
            displayUserInfo()
        }
    }
    private var profileURL: URL? {
        let urlString = currentUser.profileImageUrl
        print("DEBUG-CameraVC: return a profile img urlString")
        return URL(string: urlString)
    }
    
//MARK: - Location components
    
    private var locationManager: CLLocationManager!
    private var latFull: Double = 0
    private var longFull: Double = 0
    private var alti: Double = 0
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Locating..."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .white.withAlphaComponent(0.87)
        lb.numberOfLines = 2
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        
        lb.shadowColor = .black.withAlphaComponent(0.27)
        lb.shadowOffset = CGSize(width: 2, height: 2)
        
        return lb
    }()
    
//MARK: - Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    private let requestAccessLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Please allow us to access camera"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        lb.textColor = .white
        lb.numberOfLines = .zero
        lb.textAlignment = .center
//        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let goToSettingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go To Setting", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        btn.tintColor = .green
        btn.addTarget(self, action: #selector(goToSettingApp), for: .touchUpInside)
        
        return btn
    }()
    
    private let cameraView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.clipsToBounds = true
        return vw
    }()
    
    private let shutterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        btn.tintColor = .white
        btn.isEnabled = false //fetch userInfo first, then enable it
        btn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.8
        
        return btn
    }()
    
    private let toggleCameraButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        btn.tintColor = .white
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 26, width: 30)
        btn.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        return btn
    }()
    
    private let libraryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.tintColor = .white
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 26, width: 30)
        btn.addTarget(self, action: #selector(showLibraryVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "rectangle.split.3x3"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showAndHideGrid), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.8
        
        return btn
    }()
    
    //MARK: - Grid
    
    private var verticalView1 = UIView()
    private var verticalView2 = UIView()
    private var horizontalView1 = UIView()
    private var horizontalView2 = UIView()
    private var setUpGrid = false
    
    //MARK: - Camera components
        
    //a session camera
    private var captureSession = AVCaptureSession()
    
    //toggle of camera
    private var backFacingCamera: AVCaptureDevice?
    private var frontFacingCamera: AVCaptureDevice?
    private var currentDevice: AVCaptureDevice?
    
    //output device
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var stillImage: UIImage?
    
    //preview layer
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(rgb: 0x000000) //color code from Storyboard
        protocolVC()
        configureUI()
        checkLocationPermission() //check the Camera access
        swipeAndTapGesture()
    }
    
    private func configureUI() {
        
        view.addSubview(cameraView)
        cameraView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 44) //bottomView (safe) = 44
        cameraView.layer.cornerRadius = 16
        
        //top components
        cameraView.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 6, paddingLeft: 12)
        profileImageView.setDimensions(height: 36, width: 36)
        profileImageView.layer.cornerRadius = 36/2
        
        cameraView.addSubview(gridButton)
        gridButton.anchor(top: profileImageView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 12)
        gridButton.setDimensions(height: 32, width: 32)
        
        cameraView.addSubview(locationLabel)
        locationLabel.anchor(left: profileImageView.rightAnchor, right: gridButton.leftAnchor, paddingLeft: 12, paddingRight: 12)
        locationLabel.centerY(inView: profileImageView)
        
        //bottom components
        cameraView.addSubview(shutterButton)
        shutterButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 68) //bottomView (safe) = 44, so 24 above the custom tabBar
        shutterButton.centerX(inView: view)
        shutterButton.setDimensions(height: 90, width: 90)
        shutterButton.layer.cornerRadius = 90/2
        
        cameraView.addSubview(toggleCameraButton)
        toggleCameraButton.anchor(left: shutterButton.rightAnchor, paddingLeft: 20)
        toggleCameraButton.centerY(inView: shutterButton)
        
        cameraView.addSubview(libraryButton)
        libraryButton.anchor(right: shutterButton.leftAnchor, paddingRight: 20)
        libraryButton.centerY(inView: shutterButton)
        
        //now fetch user info and photo info
//        fetchUserData()
//        fetchAllPhotos()
    }
    
    private func configureGrid() {
        let alpha = 0.57
        verticalView1.backgroundColor = .white.withAlphaComponent(alpha)
        verticalView2.backgroundColor = .white.withAlphaComponent(0.87)
        horizontalView1.backgroundColor = .white.withAlphaComponent(alpha)
        horizontalView2.backgroundColor = .white.withAlphaComponent(0.87)
        
        cameraView.addSubview(verticalView1)
        let d1 = (view.frame.width-1)/3
        verticalView1.anchor(top: cameraView.topAnchor, left: cameraView.leftAnchor, bottom: cameraView.bottomAnchor, paddingLeft: d1, width: 0.5)
        
        cameraView.addSubview(verticalView2)
        let d2 = 0.5+2*d1
        verticalView2.anchor(top: cameraView.topAnchor, left: cameraView.leftAnchor, bottom: cameraView.bottomAnchor, paddingLeft: d2, width: 0.5)
        
        cameraView.addSubview(horizontalView1)
        let d3 = (cameraView.frame.height-1)/3
        horizontalView1.anchor(top: cameraView.topAnchor, left: cameraView.leftAnchor, right: cameraView.rightAnchor, paddingTop: d3, height: 0.5)
        
        cameraView.addSubview(horizontalView2)
        let d4 = 0.5+2*d3
        horizontalView2.anchor(top: cameraView.topAnchor, left: cameraView.leftAnchor, right: cameraView.rightAnchor, paddingTop: d4, height: 0.5)
    }
    
//MARK: - Protocols
            
    func protocolVC() {
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogIn, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-CameraVC: login notified, fetching CameraVC..")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserInfo()
        }
        runCamObserver = NotificationCenter.default.addObserver(forName: .runCam, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-CameraVC: let's run camera..")
            guard let strongSelf = self else { return }
            strongSelf.captureSession.startRunning()
        }
        
    }
    
    deinit {
        if let observer1 = logInObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        if let observer2 = runCamObserver {
            NotificationCenter.default.removeObserver(observer2)
        }
    }
    
//MARK: - Action
    
    private func swipeAndTapGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showLibraryVC))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let tapSetting = UITapGestureRecognizer(target: self, action: #selector(showMapVC))
        profileImageView.addGestureRecognizer(tapSetting)
    }
    
    @objc func showAndHideGrid() {
        if setUpGrid {
            verticalView1.isHidden = !verticalView1.isHidden
            verticalView2.isHidden = !verticalView2.isHidden
            horizontalView1.isHidden = !horizontalView1.isHidden
            horizontalView2.isHidden = !horizontalView2.isHidden
        } else {
            configureGrid()
            setUpGrid = true
        }
    }
    
    @objc func goToSettingApp() {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
    }
    
    private func showNavVC(viewController: UIViewController, style: UIModalTransitionStyle) {
        let vc = viewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = style
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func showLibraryVC() {
        let vc = LibraryViewController()
        vc.phoneCurrent = phoneUser
        showNavVC(viewController: vc, style: .coverVertical)
    }
    
    @objc func showMapVC() {
        let vc = SettingViewController()
        showNavVC(viewController: vc, style: .coverVertical)
    }
    
    private func fetchUserInfo() {
        if phoneUser == "nil" {
            if let phone = userDefault.shared.defaults.value(forKey: "currentPhone") as? String {
                print("DEBUG-CameraVC: got phoneNo from userDefault")
                phoneUser = phone
            } else {
                print("DEBUG-CameraVC: no phone number available")
            }
        }
        UserService.fetchUserInfo(phoneFull: phoneUser) { userInfo in
            print("DEBUG-CameraVC: fetching userInfo..")
            self.currentUser = userInfo
        }
    }
    
    private func displayUserInfo() {
        if currentUser.profileImageUrl == "none" {
            profileImageView.image = UIImage(systemName: "person.circle")
        } else {
            profileImageView.sd_setImage(with: profileURL)
        }
        shutterButton.isEnabled = true
    }
    
    private func setUpCameraAndUIAndLocation() {
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        currentLocation() //let's locate our current loction
        
        configureCamera()
        configureUI()
        doubleTapToToggleCam()
    }
    
    @objc func takePhoto() {
        print("DEBUG-CameraVC: shutter button tapped..")
        takePhotoAnimation()
        
//        guard let videoConnection = stillImageOutput?.connection(with: AVMediaType.video) else { return }
//
////        let's capture the photo
//        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { imageDataBuffer, error in
//
//            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer!) {
//
//                if self.currentDevice == self.frontFacingCamera {
//                    //this is only for front facing camera (gotta mirror it)
//                    print("DEBUG-CameraVC: taking photo from selfie cam")
//                    let img = UIImage(data: imageData)
//                    let image = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: .leftMirrored)
//                    self.stillImage = image //pass the modified image to "stillImage"
//                } else {
//                    //this is simply for back facing camera
//                    print("DEBUG-CameraVC: taking photo from back cam")
//                    self.stillImage = UIImage(data: imageData) //pass the captured image to "stillImage"
//                }
//                //show the capture picture
//                self.captureSession.stopRunning()
//                self.presentLocationAndImage()
//            }
//        })
        
        presentLocationAndImage()
    }
    
    
    private func presentLocationAndImage() {
//        guard let capturePhoto = stillImage else { return }
        let capturePhoto = #imageLiteral(resourceName: "tesla")
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        guard let alt = locationManager.location?.altitude else { return } //in meter
        
        let vc = ImagePreviewViewController(image: capturePhoto, latitude: lat, longitude: long, altitude: alt, phone: currentUser.phone)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
//MARK: - Configure Camera
        
    private func configureCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        //setup the camera for 2 modes (front and back)
        let devicesArray = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devicesArray {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        //default device
        currentDevice = backFacingCamera
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        do {
            //cannot execute the line below on a simulator
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput!)
            
            //setup camera preview layer
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) //add "guard" if possible
            cameraPreviewLayer?.videoGravity = .resizeAspectFill
            
            //let take care the UI
            cameraView.layer.addSublayer(cameraPreviewLayer!)
            DispatchQueue.main.async {
                self.cameraPreviewLayer?.frame = self.cameraView.bounds
            }
            captureSession.startRunning()
            
        } catch let error {
            print("DEBUG-CameraVC: error camera - \(error)")
        }
    }
    
    private func doubleTapToToggleCam() {
        let tapView = UIView()
        tapView.backgroundColor = .clear
        view.addSubview(tapView)
        tapView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: shutterButton.topAnchor, right: view.rightAnchor)
        
        let toggleCameraTap = UITapGestureRecognizer()
        toggleCameraTap.numberOfTapsRequired = 2
        toggleCameraTap.addTarget(self, action: #selector(toggle))
        tapView.addGestureRecognizer(toggleCameraTap)
        
    }
    
    @objc func toggle() {
        print("DEBUG-CameraVC: toggling camera..")
        
        captureSession.beginConfiguration()
        guard let newDevice = (currentDevice?.position == .back) ? frontFacingCamera : backFacingCamera else { return }
        
        //let's remove all sessions from the current camera state (remove all front Cam sessions to begin back Cam, vice versa)
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch let error {
            print("DEBUG: error toggle camera - \(error)")
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        //now change the camera direction
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    private func takePhotoAnimation() {
        shutterButton.backgroundColor = .white
        self.shutterButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.shutterButton.isEnabled = true
        })
        
        UIView.animate(withDuration: 0.38) {
            self.shutterButton.alpha = 0
            self.view.alpha = 0.1
        } completion: { _ in
            self.shutterButton.backgroundColor = .clear
            UIView.animate(withDuration: 0.38) {
                self.shutterButton.alpha = 1
                self.view.alpha = 1
            }
        }
    }
    
//MARK: - Privacy camera
    
    private func showLabelAccess(show: Bool, message: String) {
        //in case camera, location, micro is not accessed
        view.addSubview(goToSettingButton)
        goToSettingButton.centerY(inView: view)
        goToSettingButton.centerX(inView: view)
        
        view.addSubview(requestAccessLabel)
        requestAccessLabel.anchor(left: view.leftAnchor, bottom: goToSettingButton.topAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 12, paddingRight: 20)
        requestAccessLabel.centerX(inView: view)
        requestAccessLabel.text = message
        
        requestAccessLabel.isHidden = !show
        goToSettingButton.isHidden = !show
    }
    
    private func checkCameraPermissions() {
        didCheckCameraPermission = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        
        case .notDetermined:
            //let's request it
            print("DEBUG-CameraVC: camera access is notDetermined")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted == true {
                    DispatchQueue.main.async {
                        print("DEBUG-CameraVC: camera access granted")
                        self?.showLabelAccess(show: false, message: "None")
//                        self?.setUpCameraAndUIAndLocation()
                        self?.currentLocation()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DEBUG-CameraVC: camera access rejected")
                        self?.showLabelAccess(show: true, message: "Please allow to access Camera")
                    }
                }
                
            }
        case .restricted, .denied:
            print("DEBUG-CameraVC: camera access is restricted/denied")
            showLabelAccess(show: true, message: "Please allow to access Camera")
        case .authorized:
            print("DEBUG-CameraVC: camera access is authorized")
            self.showLabelAccess(show: false, message: "None")
//            self.setUpCameraAndUIAndLocation()
            self.currentLocation()
        @unknown default:
            break
        }
    }
    
//MARK: - identify location
    
    private func currentLocation() {
        print("DEBUG-CameraVC: locating current...")
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        displayLocation()
    }
    
    private func displayLocation() {
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        
        //showing the address (we got an extension (LocationAddress) for this)
        let location = CLLocation(latitude: lat, longitude: long)
        location.placemark { placemark, error in
            if let e = error?.localizedDescription {
                print("DEBUG-CameraVC: error locating \(e)")
                return
            }
            guard let pin = placemark else { return }
            guard let cty = pin.city else { return }
            guard let adArea = pin.administrativeArea?.description else { return }
            guard let street = pin.streetName else { return }
//            let placeName = pin.subLocality ?? ""
            
            print("DEBUG-CameraVC: done locating - \(street) \(cty), \(adArea)")
            self.locationLabel.text = "\(street), \(cty), \(adArea)"
        }
    }
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension CameraViewController: CLLocationManagerDelegate {
    
    //this func will check the location status of the app
    func checkLocationPermission() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        case .notDetermined:
            print("DEBUG-CameraVC: location notDetermined")
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("DEBUG-CameraVC: location restricted/denied")
            showLabelAccess(show: true, message: "Please allow to access Location")
            break
        case .authorizedAlways, .authorizedWhenInUse: //so this app on simulator only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG-CameraVC: location access is always/WhenInUse")
            checkCameraPermissions()
            
        @unknown default:
            print("DEBUG: location default")
            break
        }
    }
    
    //let's evaluate the location status, it activates after we done picking a case in func "checkLocationPermission" and whenever we open the app
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG-CameraVC: current location status is whenInUse")
            if didCheckCameraPermission {
                print("DEBUG-CameraVC: did check CameraPermission, no need to check it again")
            } else {
                checkCameraPermissions()
            }
            
        } else if status == .authorizedAlways {
            print("DEBUG-CameraVC: current location status is always")
            if didCheckCameraPermission {
                print("DEBUG-CameraVC: already check CameraPermission, no need to check it again")
            } else {
                checkCameraPermissions()
            }
            
        } else if status == .denied {
            print("DEBUG-CameraVC: current location status is denied")
            showLabelAccess(show: true, message: "Please allow to access Location")
        }
    }
}

