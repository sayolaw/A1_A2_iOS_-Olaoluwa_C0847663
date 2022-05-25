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
    var distance = 0.0
    var destinationa: CLLocationCoordinate2D!
    var destinationb: CLLocationCoordinate2D!
    var destinationc: CLLocationCoordinate2D!
    var coordinatesArr = [CLLocationCoordinate2D]()
    var userLocation = CLLocation()
    var pressCount = 0
    
    func getDirections(source:CLLocationCoordinate2D,newdestination:CLLocationCoordinate2D){
        let sourcePlaceMark = MKPlacemark(coordinate: source)
        let destinationPlaceMark = MKPlacemark(coordinate: newdestination)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    @IBAction func Directions(_ sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
        getDirections(source:destinationa, newdestination: destinationb)
        getDirections(source:destinationb, newdestination: destinationc)
        getDirections(source:destinationc, newdestination: destinationa)
        
    }
    
    @IBOutlet weak var displayArea: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
//        mapView.isZoomEnabled = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let lngTap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(lngTap)

    
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.ended{
        pressCount += 1
        print(pressCount)
        var title:String;
        
            let pressPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(pressPoint, toCoordinateFrom: mapView)
            
            switch pressCount{
                        case 1:
                            title = "A"
                            destinationa = coordinate
                            
                        case 2:
                            title = "B"
                            destinationb = coordinate
                        case 3:
                            title = "C"
                            destinationc = coordinate
                        default:
                            title = "Outside Bounds"
            }
            let nextLocation = CLLocation(latitude: lat, longitude: lng)
            let thisLocation = CLLocation(latitude:coordinate.latitude, longitude: coordinate.longitude)
            
           
            
            
            distance = (thisLocation.distance(from:nextLocation))/1000.00
            
            print("\(distance) Km");
            coordinatesArr.append(coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.subtitle = "\(distance)Km"
            annotation.title = title
            mapView.addAnnotation(annotation)
            if(pressCount==3){
                addPolygon()
            }
            if(pressCount==4){
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
                displayLocation(latitude: lat, longitude: lng, title: "User Location", subtitile: "This is the user location")
                coordinatesArr.removeAll()
                coordinatesArr.append(coordinate)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.subtitle = "\(distance)Km"
                annotation.title = title
                mapView.addAnnotation(annotation)
                
                pressCount = 1
            }
        }
    }
    func addPolygon() {
      
        var polArr = [CLLocationCoordinate2D]()
        for i in mapView.annotations{
            if(i.title != "User" ){
                polArr.append(i.coordinate)
            }
            else{
                
            }
        }
        let coordinates = polArr.map {$0}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
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
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = location
            pin.subtitle = "User Location"
            pin.title = "User"
            mapView.addAnnotation(pin)

    
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.removeAnnotation(view.annotation!)
        pressCount -= 1
        mapView.removeOverlays(mapView.overlays)
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Distance From Location", message: "Hello", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }

           if annotation.title != "User"{
               print("we are here")
               let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppable")
               annotationView.animatesDrop = true
               annotationView.pinTintColor = .green
               annotationView.canShowCallout = true
               annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

               
               
               return annotationView
           }
             
           else{
               print("we are not here")
               return nil
           }
           return nil
       
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }
        return MKOverlayRenderer()
    }



}

