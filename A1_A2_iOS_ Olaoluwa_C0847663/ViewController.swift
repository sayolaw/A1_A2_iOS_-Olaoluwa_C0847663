//
//  ViewController.swift
//  A1_A2_iOS_ Olaoluwa_C0847663
//
//  Created by Sayo Lawal on 2022-05-24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate  {
    var locationManager = CLLocationManager()
    var lat = CLLocationDegrees()
    var lng = CLLocationDegrees()
    @IBOutlet weak var displayArea: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        mapView.isZoomEnabled = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lat = location?.coordinate.latitude ?? 0.0
        lng = location?.coordinate.longitude ?? 0.0
        displayLocation(latitude:lat, longitude: lng, title: "User", subtitile: "My location")
        if let location = location {
            CLGeocoder().reverseGeocodeLocation(location){ placemarks, error in
                if error != nil{
                    print(error!)
                }
                else{
                    DispatchQueue.main.async {
                        if let placemark = placemarks?[0]{
                            var address = ""
                            if placemark.subThoroughfare != nil {
                                address += placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                address += placemark.thoroughfare! + "\n "
                            }
                            if placemark.subLocality != nil {
                                address += placemark.subLocality! + "\n"
                            }
                            if placemark.administrativeArea != nil {
                                address += placemark.administrativeArea! + ","
                            }
                            if placemark.postalCode != nil {
                                address += placemark.postalCode! + "\n"
                                print(placemark.postalCode)
                            }
                            if placemark.country != nil {
                                address += placemark.country! + " "
                                print(address)
                            }
                            self.displayArea.numberOfLines = 0
                          self.displayArea.text = address
                        }
                    }
                    
                }
            }
            
        }

    }
    func displayLocation(
        latitude:CLLocationDegrees,
        longitude:CLLocationDegrees,
        title: String,
        subtitile: String){
            let latDelta: CLLocationDegrees = 0.05
            let lngDelat:CLLocationDegrees = 0.05
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelat)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = location
            pin.subtitle = "User Location"
            pin.title = "User"
            mapView.addAnnotation(pin)

    
    }



}

