//
//  ImagePreviewViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 1/9/22.
//

import UIKit
import CoreLocation

class ImagePreviewViewController: UIViewController {

    private var lat: CLLocationDegrees
    private var long: CLLocationDegrees
    private var alt: CLLocationDegrees
    private var phoneCurrent: String
    
    private var titleNote = "no title" //for rename title
    
//MARK: - Components
    
    private var bigImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "car")
        
        return iv
    }()
    
    private let dismissBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        return btn
    }()
    
    //save button
    private let saveView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .yellow
        vw.layer.cornerRadius = 16
        
        return vw
    }()
    
    private let saveLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Save"
        lb.textColor = .black
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return lb
    }()
    
    private let saveIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .black
        iv.image = UIImage(systemName: "arrow.down.to.line.compact")
        
        return iv
    }()
    
    //send button
    private let sendView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .green
        vw.layer.cornerRadius = 16
        
        return vw
    }()
    
    private let sendLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Send"
        lb.textColor = .black
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return lb
    }()
    
    private let sendIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .black
//        iv.image = UIImage(systemName: "arrowtriangle.forward.fill")
        iv.image = UIImage(systemName: "arrow.forward")
        
        return iv
    }()
    
    
//MARK: - View Scenes
    
    init(image: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDegrees, phone: String) {
        self.bigImageView.image = image
        self.lat = latitude
        self.long = longitude
        self.alt = altitude
        self.phoneCurrent = phone
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        configureUI()
        tapGesture()
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureUI() {
        view.addSubview(bigImageView)
        bigImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 46)
        bigImageView.layer.cornerRadius = 16
        
        view.addSubview(dismissBtn)
        dismissBtn.anchor(top: bigImageView.bottomAnchor, paddingTop: 8, width: 32, height: 32)
        dismissBtn.centerX(inView: view)
        
        //save button
        view.addSubview(saveView)
        saveView.anchor(top: bigImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 12, width: 88, height: 32)
        
        saveView.addSubview(saveIcon)
        saveIcon.anchor(right: saveView.rightAnchor, paddingRight: 12, width: 20, height: 20)
        saveIcon.centerY(inView: saveView)
        
        saveView.addSubview(saveLabel)
        saveLabel.anchor(left: saveView.leftAnchor, right: saveIcon.leftAnchor, paddingLeft: 12, paddingRight: 2)
        saveLabel.centerY(inView: saveView)
        
        //send button
        view.addSubview(sendView)
        sendView.anchor(top: bigImageView.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingRight: 12, width: 88, height: 32)
        
        sendView.addSubview(sendIcon)
        sendIcon.anchor(right: sendView.rightAnchor, paddingRight: 12, width: 20, height: 20)
        sendIcon.centerY(inView: sendView)
        
        sendView.addSubview(sendLabel)
        sendLabel.anchor(left: sendView.leftAnchor, right: sendIcon.leftAnchor, paddingLeft: 12, paddingRight: 2)
        sendLabel.centerY(inView: sendView)
    }
    
    private func tapGesture() {
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(setTitle))
        let sendTap = UITapGestureRecognizer(target: self, action: #selector(sendTo))
        saveView.addGestureRecognizer(saveTap)
        sendView.addGestureRecognizer(sendTap)
    }
    
//MARK: - Action
    
    @objc func setTitle() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Title", message: "Please name this picture.", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                
                self.showLoadingView(true, message: "Saving")
                self.titleNote = textField.text!
                print("DEBUG-ImgPreVC: title created: \(self.titleNote)")
                self.savePictAndLocation(titleTyped: self.titleNote)
                
            } else {
                print("DEBUG-ImgPreVC: textField is empty..")
                self.alert(error: "Please enter a title", buttonNote: "Try again")
            }
        }
        
        alertBox.addTextField { (alertTextField) in
            alertTextField.placeholder = "Where are you now?"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField //set customized textField to be equal to alert default textField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    private func savePictAndLocation(titleTyped: String) {
        guard let img = bigImageView.image else {
            print("DEBUG-ImagePreviewVC: cannot get the captured image")
            return
        }
        Time.configureTimeNow { timeArr in
            let data = [
                "latitude": self.lat,
                "longitude": self.long,
                "altitude": self.alt,
                "title": titleTyped,
                "timestamp": timeArr[1],
                "date": timeArr[0],
                "imageURL": "no url"
            ] as [String : Any]
            
            let newSaveImg = Picture(dictionary: data)
            UploadInfo.uploadLocationAndPhoto(userPhone: self.phoneCurrent, takenImage: img, photoInfo: newSaveImg, dictionary: data, text: titleTyped) { error in
                self.showLoadingView(false)
                if let e = error?.localizedDescription {
                    self.alert(error: e, buttonNote: "OK")
                    return
                }
                self.dismissVC()
            }
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .runCam, object: nil)
    }
    
    @objc func sendTo() {
        
    }
    
    

}
