//
//  MapPhotoViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 1/10/22.
//

import UIKit
import MapKit
import Firebase
import SDWebImage

private let annoID = "photoIdentifier"

class MapPhotoViewController: UIViewController {
    
    var photoLocationInfo: Picture? {
        didSet {
            imageAnno.sd_setImage(with: imageURL)
            navigationItem.title = photoLocationInfo?.title
        }
    }
    
    private var imageURL: URL? {
        return URL(string: photoLocationInfo?.imageUrl ?? "no url")
    }
    
    var titleChanged = "title changed"
    private var didRename = false
    
    private let mapView = MKMapView()
    private var locationManager: CLLocationManager!
    private var route: MKRoute? //use this to generate polyline
    
//MARK: - Components
    
    //this var is added into the annotation view
    private var imageAnno: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "questionmark")
        iv.backgroundColor = .green.withAlphaComponent(0.87)
        iv.isUserInteractionEnabled = true
        
        iv.layer.cornerRadius = 12
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.black.cgColor
        
        return iv
    }()
    
    private let openMapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Open Map", for: .normal)
        btn.backgroundColor = .black
        btn.tintColor = .green
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.green.cgColor
        btn.layer.cornerRadius = 12
        
        btn.addTarget(self, action: #selector(openMapButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let bottomView = MapBottomView()
    
    private let bottomCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        vw.alpha = 0.67
        return vw
    }()
    
    private let distanceView: UIView = {
        let vw = UIView()
//        vw.backgroundColor = .lightGray.withAlphaComponent(0.67)
        vw.backgroundColor = .white
        vw.layer.shadowOffset = CGSize(width: 2, height: 2)
        vw.layer.shadowOpacity = 0.67
        vw.layer.shadowColor = UIColor.black.cgColor
        
        return vw
    }()
    
    private var distanceLabel: UILabel = {
        let lb = UILabel()
        lb.text = "... mi"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.numberOfLines = 1
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    
//MARK: - View Scenes

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureMapView()
        enableLocationService() //locate the current loca immediately
        constructLocation()
        tapImage()
    }
    
    //let's set default color for status bar
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .darkContent
//    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        //set multiple barButtonItems on the right
        let btn1 = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .done, target: self, action: #selector(editItem))
        let btn2 = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(deleteItem))
        navigationItem.setRightBarButtonItems([btn1, btn2], animated: true)
        
        //bottom view
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
        bottomView.delegate = self
        
        view.addSubview(bottomCover)
        bottomCover.anchor(top: bottomView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        //openMap button
        mapView.addSubview(openMapButton)
        openMapButton.anchor(bottom: mapView.bottomAnchor, paddingBottom: 12, width: 120, height: 40)
        openMapButton.centerX(inView: mapView)
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: bottomView.topAnchor, right: view.rightAnchor)
        mapView.overrideUserInterfaceStyle = .light
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //dot will move if current location moves
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
        
        //distance
        mapView.addSubview(distanceView)
        distanceView.anchor(top: mapView.safeAreaLayoutGuide.topAnchor, right: mapView.rightAnchor, paddingTop: 12, paddingRight: 12, width: 70, height: 24)
        distanceView.layer.cornerRadius = 10
        
        distanceView.addSubview(distanceLabel)
        distanceLabel.anchor(left: distanceView.leftAnchor, right: distanceView.rightAnchor, paddingLeft: 4, paddingRight: 4)
        distanceLabel.centerY(inView: distanceView)
    }
    
//MARK: - Actions
    
    @objc func openMapButtonTapped() {
        guard let lat = photoLocationInfo?.latitude else { return }
        guard let long = photoLocationInfo?.longitude else { return }
        guard let name = photoLocationInfo?.title else { return }
        
        openMap(lati: lat, longi: long, nameMap: name)
    }
    
    private func tapImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapping))
        imageAnno.addGestureRecognizer(tap)
    }
    
    @objc func tapping() {
        guard let pictureInfo = photoLocationInfo else { return }
        let vc = ImageViewController(imageInfo: pictureInfo)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func deleteItem() {
        
    }
    
    @objc func editItem() {
        textBox()
    }
    
//MARK: - TextBox and title change
    
    private func textBox() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Edit title", message: "Rename to...", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                
                self.showLoadingView(true, message: "Saving")
                self.titleChanged = textField.text!
                print("DEBUG-MapPhotoVC: title update is \(self.titleChanged)")
                self.updateTitle()
                
            } else {
                print("DEBUG-MapPhotoVC: textField is empty..")
                self.alert(error: "Please enter a valid input", buttonNote: "Try again")
            }
        }
        alertBox.addTextField { (alertTextField) in
            guard let currentTitle = self.photoLocationInfo?.title else { return }
            alertTextField.text = currentTitle
            alertTextField.placeholder = "New title"
            alertTextField.autocapitalizationType = .words
            
            textField = alertTextField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    private func updateTitle() {
        print("DEBUG-MapPhotoVC: updating title..")
        guard let userPhone = Auth.auth().currentUser?.phoneNumber else { return }
        guard let time = photoLocationInfo?.timestamp else { return }
        
        let data = ["title": titleChanged] as [String: Any]
        
        Firestore.firestore().collection("users").document(userPhone).collection("library").document(time).updateData(data) { error in
            
            self.showLoadingView(false, message: "Saving")
            if let e = error?.localizedDescription {
                print("DEBUG: error updating title - \(e)")
                self.showLoadingView(false)
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            print("DEBUG-MapPhotoVC: successfully update title")
            self.navigationItem.title = self.titleChanged
            self.didRename = true
        }
        
    }
    
//MARK: - Construct Map
    
    private func zoomToAnnotation() {
        guard let lat = photoLocationInfo?.latitude else { return }
        guard let long = photoLocationInfo?.longitude else { return }
        
        let locationAnno = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let savedPlace = locationAnno
        let region = MKCoordinateRegion(center: savedPlace, latitudinalMeters: 2000, longitudinalMeters: 2000) //we got 2000 meters around the location
        mapView.setRegion(region, animated: true)
    }
    
    private func zoomTwoAnnotation() {
        //let's show all annotations on map, including the current location
        let twoAnnotation = mapView.annotations
        mapView.showAnnotations(twoAnnotation, animated: true)
        mapView.zoomToFit(annotations: twoAnnotation)
    }
    
    private func constructLocation() {
        guard let timeTaken = photoLocationInfo?.timestamp else { return }
        guard let lati = photoLocationInfo?.latitude else { return }
        guard let longi = photoLocationInfo?.longitude else { return }
        
        //let's add an annotation to savedLocation
        let locationAnno = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        let annoPhoto = PictureAnnotation(time: timeTaken, coorPicture: locationAnno)
        annoPhoto.coordinate = locationAnno
        mapView.addAnnotation(annoPhoto)
        mapView.selectAnnotation(annoPhoto, animated: true) //make anno big
//        didAddPhotoAnno = true
        
        //re-center the location for user to see it clearly
        zoomToAnnotation()
        
        //now calculate the distance
        distanceInMile(lat: lati, long: longi)
        
        //let's generate a polyline to the Location
        generatePolyline(toCoor: locationAnno)
    }
    
    private func distanceInMile(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let currentLoca = locationManager.location else { return }
        let savedLocation = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = currentLoca.distance(from: savedLocation)
        print("DEBUG-MapPhotoVC: distance is \(distanceInMeters) meters")
        
        let distanceMile = distanceInMeters / 1609
        let d = String(format: "%.1f", distanceMile) //round to 1 decimals

        self.distanceLabel.text = "\(d) mi"
    }
    
    //remember to add the extension "MKMapViewDelegate" below
    func generatePolyline(toCoor: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: toCoor)
        let mapSavedPlace = MKMapItem(placemark: placemark)
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapSavedPlace
        request.transportType = .automobile

        let directionResquest = MKDirections(request: request)
        directionResquest.calculate { (res, error) in
            guard let response = res else { return }
            self.route = response.routes[0] //there are many routes lead to a destination, we just take the first route
            print("DEBUG-MapPhotoVC: we have \(response.routes.count) routes")
            guard let polyline = self.route?.polyline else {
                print("DEBUG-MapPhotoVC: no polyline")
                return
            }
            self.mapView.addOverlay(polyline) //let's add the polyline
        }
    }

}

//MARK: - MapViewDelegate
//remember to write "MapView.delegate = self" in viewDidLoad
extension MapPhotoViewController: MKMapViewDelegate {
    
    //let's modify the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    //let's configure the picture anno
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationPhoto = annotation as? PictureAnnotation {
            let vw = MKAnnotationView(annotation: annotationPhoto, reuseIdentifier: annoID)
            vw.backgroundColor = .clear
            vw.setDimensions(height: 130, width: 100)
            
            vw.addSubview(imageAnno)
            imageAnno.anchor(top: vw.topAnchor, left: vw.leftAnchor, bottom: vw.bottomAnchor, right: vw.rightAnchor)
            
            return vw
        }
        return nil
    }
    
}

//MARK: - Protocol from MapBottomView
//remember to write ".delegate = self" in viewDidLoad
extension MapPhotoViewController: MapBottomViewDelegate {
    func zoomIn() {
        zoomToAnnotation()
    }
    
    func zoomOut() {
        zoomTwoAnnotation()
    }
    
    func sendTo() {
        
    }
    
    func shareTo() {
        guard let latitude = photoLocationInfo?.latitude else { return }
        guard let longitude = photoLocationInfo?.longitude else { return }

        let urlString = MapExtension.sharingLocationURL(lat: latitude, long: longitude)

        guard let LocationUrl = URL(string: urlString) else { return }

        let shareText = "Share Location"

        let vc = UIActivityViewController(activityItems: [shareText, LocationUrl], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    func dismissMapPhoto() {
            navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension MapPhotoViewController: CLLocationManagerDelegate {
    
    //let do some alerts location
    func alertLocation () {
        
        let alert = UIAlertController (title: "Location needed", message: "Please allow GoodPlaces to access your location in Setting", preferredStyle: .alert)
        let action1 = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action2 = UIAlertAction (title: "Setting", style: .default) { (action) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present (alert, animated: true, completion: nil)
    }
    
    //this func will check the location status of the app and enable us to obtain the coordinates of the user.
    //remember to call it in ViewDidLoad
    func enableLocationService() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        //this case is the default case
        case .notDetermined:
            print("DEBUG-MapPhotoVC: location notDetermined")
            //locationManager?.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("DEBUG-MapPhotoVC: location restricted/denied")
            alertLocation()
            break
        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG-MapPhotoVC: location always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        case .authorizedWhenInUse:
            print("DEBUG-MapPhotoVC: location whenInUse")
            //locationManager?.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        @unknown default:
            print("DEBUG-MapPhotoVC: location default")
            break
        }
    }
    
    //let's evaluate the case from HomeVC, it activates after we done picking a case in func "enableLocationService"
    //this one need inheritance from "CLLocationManagerDelegate"
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG-MapPhotoVC: current status is whenInUse, requesting always")
            //locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        } else if status == .authorizedAlways {
            print("DEBUG-MapPhotoVC: current status is always")
        } else if status == .denied {
            print("DEBUG-MapPhotoVC: current status is denied")
            alertLocation()
        }
    }
    
    
}
