//
//  MapViewController.swift
//  OverHere
//
//  Created by Long Nguyen on 2/17/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let mapView = MKMapView()
    private var locationManager: CLLocationManager!
    private var route: MKRoute? //use this to generate polyline
    
//MARK: - Components
    
    private let backgroundView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.clipsToBounds = true
        return vw
    }()
    
    private let sideView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    //now build the search view
    private let searchView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black.withAlphaComponent(0.17)
        vw.layer.cornerRadius = 16
        vw.isUserInteractionEnabled = true
        return vw
    }()
    
    private let searchSymbol: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = .gray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let searchLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Search..."
        lb.textColor = .gray
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        return lb
    }()
    
    
//MARK: - View Scene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        configureMapView()
        configureUI()
        addTap()
//        enableLocationService() //locate the current loca immediately
    }
    
    private func configureUI() {
        mapView.addSubview(sideView)
        sideView.anchor(top: backgroundView.topAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, width: 20)
        
        //add the searchView
        mapView.addSubview(searchView)
        searchView.anchor(top: backgroundView.topAnchor, paddingTop: 12, width: 240, height: 40)
        searchView.centerX(inView: backgroundView)
        
        searchView.addSubview(searchSymbol)
        searchSymbol.anchor(left: searchView.leftAnchor, paddingLeft: 12, width: 26, height: 26)
        searchSymbol.centerY(inView: searchView)
        
        searchView.addSubview(searchLabel)
        searchLabel.anchor(left: searchSymbol.rightAnchor, right: searchView.rightAnchor, paddingLeft: 4, paddingRight: 8)
        searchLabel.centerY(inView: searchSymbol)
    }
    
    private func configureMapView() {
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 44) //bottomView (safe) = 44
        backgroundView.layer.cornerRadius = 16
        
        backgroundView.addSubview(mapView)
        mapView.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor)
        mapView.overrideUserInterfaceStyle = .light
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //dot will move if current location moves
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
    }
    
//MARK: - Actions
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(searching))
        searchView.addGestureRecognizer(tap)
    }
   
    @objc func searching() {
        print("DEBUG-MapVC: searching...")
        
    }
}

//MARK: - MapViewDelegate
//remember to write "MapView.delegate = self" in viewDidLoad
extension MapViewController: MKMapViewDelegate {
    
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
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
//extension MapViewController: CLLocationManagerDelegate {
//
//    //let do some alerts location
//    private func alertLocation () {
//
//        let alert = UIAlertController (title: "Location needed", message: "Please allow GoodPlaces to access your location in Setting", preferredStyle: .alert)
//        let action1 = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
//        let action2 = UIAlertAction (title: "Setting", style: .default) { (action) in
//            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
//        }
//
//        alert.addAction(action1)
//        alert.addAction(action2)
//        present (alert, animated: true, completion: nil)
//    }
//
//    //this func will check the location status of the app and enable us to obtain the coordinates of the user.
//    //remember to call it in ViewDidLoad
//    private func enableLocationService() {
//
//        locationManager = CLLocationManager()
//        locationManager?.delegate = self
//
//        switch CLLocationManager.authorizationStatus() {
//
//        //this case is the default case
//        case .notDetermined:
//            print("DEBUG-MapVC: location notDetermined")
//            //locationManager?.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
//            locationManager.requestAlwaysAuthorization()
//        case .restricted, .denied:
//            print("DEBUG-MapPhotoVC: location restricted/denied")
//            alertLocation()
//            break
//        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
//            print("DEBUG-MapPhotoVC: location always")
//            locationManager?.startUpdatingLocation()
//            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
//        case .authorizedWhenInUse:
//            print("DEBUG-MapPhotoVC: location whenInUse")
//            //locationManager?.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
//        @unknown default:
//            print("DEBUG-MapPhotoVC: location default")
//            break
//        }
//    }
//
//    //activates after we done picking a case in func "enableLocationService"
//    //this one need inheritance from "CLLocationManagerDelegate"
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//        if status == .authorizedWhenInUse {
//            print("DEBUG-MapPhotoVC: current status is whenInUse, requesting always")
//            //locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
//        } else if status == .authorizedAlways {
//            print("DEBUG-MapPhotoVC: current status is always")
//        } else if status == .denied {
//            print("DEBUG-MapPhotoVC: current status is denied")
//            alertLocation()
//        }
//    }
//
//
//}
