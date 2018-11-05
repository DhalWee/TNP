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
import Alamofire
import SwiftyJSON

class MainMapPage: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var myLocation: CLLocation = CLLocation()
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    var parkingPlaces: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 37.329398, longitude: -122.031365),
                                                   CLLocationCoordinate2D(latitude: 37.323356421896314, longitude: -122.03960862010717),
                                                   CLLocationCoordinate2D(latitude: 37.343130655841115, longitude: -122.04149689525366)]

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
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        putMarks()
//        putRoad(to: parkingPlaces[1])
        
        
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
            bv.alpha = 0.4
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
    
    func putRoad(to: CLLocationCoordinate2D) {
        mapView.clear()
        putMarks()
        setNewMarker(setMyMarkerView(), myLocation)
        
        let origin = "\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)"
        let destination = "\(to.latitude),\(to.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleAPI)"
        let url = URL(string: urlString)
        
        Alamofire.request(url!).responseJSON { (response) in
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(hex: blue)
                    polyline.map = self.mapView
                }
            } catch let error as NSError {
                print("MSG: json error \(error)")
            }
        }
        
    }
    
    func putMarks() {
        for i in 0..<parkingPlaces.count {
            let coordinate = parkingPlaces[i]
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            var markerView = UIView()
            if i < 1 {
                markerView = setNewMarkerView(color: UIColor(hex: yellow), label: "\(i+1)")
            } else {
                markerView = setNewMarkerView(color: UIColor(hex: green), label: "\(i+1)")
            }
            
            setNewMarker(markerView, location)
            print("Added: \(i) marker")
        }
    }
    
}

//Map delegation
extension MainMapPage: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.last!
        print("Location: \(myLocation)")
        
        let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude,
                                              longitude: myLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        setNewMarker(setMyMarkerView(), myLocation)
        
        
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        putRoad(to: marker.position)
        return true
    }
}
