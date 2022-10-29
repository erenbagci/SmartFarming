//
//  MapDetails.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 26.06.2022.
//

import UIKit
import MapKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class MapDetailsViewController: UIViewController, MKMapViewDelegate {
    
    var allFarms: [FarmModel] = []
    @IBOutlet weak var detailsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsMapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addAnnotations()
    }
    
    func addAnnotations() {
        
        // TODO: allFarms'taki tarlaların konumlarını haritaya ekle

        for farm in allFarms {
            if let farmLatitude = farm.farmLatitude, let latitude = Double(farmLatitude),
                let farmLongitude = farm.farmLongitude, let longitude = Double(farmLongitude) {
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                let region = MKCoordinateRegion(center: location, span: span)
                self.detailsMapView.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = FarmGlobal.sharedInstance.farmName
                self.detailsMapView.addAnnotation(annotation)
            }
        }
        

        
//        let location2 = CLLocationCoordinate2D(latitude: 31.990, longitude: 30.969)
//        let span2 = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
//        let region2 = MKCoordinateRegion(center: location2, span: span2)
//        self.detailsMapView.setRegion(region2, animated: true)
//        let annotation2 = MKPointAnnotation()
//        annotation2.coordinate = location2
//        annotation2.title = FarmGlobal.sharedInstance.farmName
//        self.detailsMapView.addAnnotation(annotation2)
        
//        let addAnotation = MKPointAnnotation()
//        addAnotation.title = "YOUR TITLE"
//        addAnotation.coordinate = CLLocationCoordinate2D(latitude: 31.990, longitude: 30.969)
//        self.detailsMapView.addAnnotation(addAnotation)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
//        if self.chosenLongitude != 0.0 && self.chosenLatitude != 0.0 {
//            let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
//
//            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
//                if let placemark = placemarks {
//
//                    if placemark.count > 0 {
//
//                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
//                        let mapItem = MKMapItem(placemark: mkPlaceMark)
//                        //mapItem.name = self.farmNameText.text
//
//                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
//
//                        mapItem.openInMaps(launchOptions: launchOptions)
//                    }
//
//                }
//            }
//
//        }
//    }
}

