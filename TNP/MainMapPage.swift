//
//  ViewController.swift
//  TNP
//
//  Created by baytoor on 10/29/18.
//  Copyright © 2018 alish. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SnapKit

class MainMapPage: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.red
        
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem.init()
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        self.navigationController?.isNavigationBarHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.76, longitude: 151.20, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        for i in 0..<3 {
            let coordinate = CLLocationCoordinate2D(latitude: Double("-37.3323314\(i)")!, longitude: Double("-122.0312186\(i)")!)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let markerView = setNewMarkerView(color: UIColor(hex: green), label: "\(i)")
            setNewMarker(markerView, location)
        }
        
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        
    }

//    lazy var leftStack: UIStackView = {
//        let stack = UIStackView.init(arrangedSubviews: [])
//
//        stack.spacing = 10
//        stack.distribution = .fill
//        stack.axis = NSLayoutConstraint.Axis.vertical
//        return stack
//    }()


}


//Functions
extension MainMapPage {
    func setNewMarkerView(color: UIColor, label: String) -> UIView {
        
        let backView: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 25
            bv.layer.masksToBounds = true
            return bv
        }()
        
        backView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        let viewShadow: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 25
            bv.layer.masksToBounds = true
            bv.alpha = 0.2
            bv.backgroundColor = color
            return bv
        }()
        
        let view2: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 20
            bv.layer.masksToBounds = true
            bv.backgroundColor = color
            return bv
        }()
        
        let markerLbl: UILabel = {
            let lbl = UILabel()
            lbl.text = label
            lbl.textColor = UIColor.white
            lbl.font = UIFont.systemFont(ofSize: 20)
            return lbl
        }()
        
        
        backView.addSubview(viewShadow)
        backView.addSubview(view2)
        backView.addSubview(markerLbl)
        
        viewShadow.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView)
        }
        view2.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView)
        }
        markerLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView)
        }
        
        return backView
    }
    
    func setMyMarkerView() -> UIView {
        
        let backView: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 18
            bv.layer.masksToBounds = true
            return bv
        }()
        
        backView.snp.makeConstraints { (make) in
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        
        let viewShadow: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 18
            bv.layer.masksToBounds = true
            bv.alpha = 0.2
            bv.backgroundColor = UIColor(hex: blue)
            return bv
        }()
        
        let view2: UIView = {
            let bv = UIView()
            bv.layer.cornerRadius = 8
            bv.layer.masksToBounds = true
            bv.backgroundColor = UIColor(hex: blue)
            return bv
        }()
        
        
        
        backView.addSubview(viewShadow)
        backView.addSubview(view2)
        
        viewShadow.snp.makeConstraints { (make) in
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView)
        }
        view2.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView)
        }
        
        return backView
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    func setNewMarker(_ markerView: UIView,_ location: CLLocation) {
        let marker = GMSMarker()
        marker.iconView = markerView
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
    }
    
}

//Map delegation
extension MainMapPage: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        setNewMarker(setMyMarkerView(), location)
        
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
