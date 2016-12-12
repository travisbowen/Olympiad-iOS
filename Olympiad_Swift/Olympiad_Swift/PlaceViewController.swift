//
//  PlaceViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 11/28/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import GooglePlaces

class PlaceViewController: UIViewController, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var camera:GMSCameraPosition!
    var mapView:GMSMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
//        camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        mapView.isMyLocationEnabled = true
//        view = mapView
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.locationManager.stopUpdatingLocation()
        
        camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 25.0)
        self.mapView.padding = mapInsets
        view = mapView
        
        
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location!.coordinate.latitude),\(location!.coordinate.longitude)&radius=10000&type=gym&sensor=true&key=AIzaSyDMujb6fPtfh3HJXr6KclH9xcRFY-PDkAU")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil{
                print("Error")
            } else {
                if let content = data{
                    let responseString = try! JSONSerialization.jsonObject(with: content, options: .allowFragments) as! NSDictionary
                        
                    let results = responseString["results"] as? [AnyObject]
                        
                    for result in results!{
                            
                        let name = result["name"] as! String
                        var latitude : Double!
                        var longitude : Double!
                            
//                      print(name)
                            
                        if let geometry = result["geometry"] as? NSDictionary{
                            if let location = geometry["location"] as? NSDictionary{
                                if let lat = location["lat"] as? Double{
                                    latitude = lat
//                                  print(latitude)
                                }
                                if let long = location["lng"] as? Double{
                                    longitude = long
//                                       print(longitude)
                                }
                            }
                        }
                            
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        marker.title = name
                        marker.map = self.mapView
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error" + error.localizedDescription)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
