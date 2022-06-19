//
//  DetailsVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 17.06.2022.
//

import UIKit
import MapKit
import Firebase

class DetailsVC: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var farmNameLabel: UILabel!
    @IBOutlet weak var harvestDateLabel: UILabel!
    @IBOutlet weak var plantedDateLabel: UILabel!
    @IBOutlet weak var plantedVegetablesLabel: UILabel!
    @IBOutlet weak var detailsMapView: MKMapView!
    var placeNameArray = [String]()
    var documentIdArray = [String]()

    
    var farmNameArray = [String]()
    var plantedVegetablesArray = [String]()
    var plantedDateArray = [String]()
    var harvestDateArray = [String]()
    var selectedPlaceId = ""
    
    
      var chosenPlaceId = ""
      
      var chosenLatitude = Double()
      var chosenLongitude = Double()
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromFirestore()
        print(chosenLatitude)
        detailsMapView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    func getDataFromFirestore() {

        let fireStoreDatabase = Firestore.firestore()
                
                /*let settings = fireStoreDatabase.settings
                settings.areTimestampsInSnapshotsEnabled = true
                fireStoreDatabase.settings = settings
         */
                fireStoreDatabase.collection("Farm").addSnapshotListener { (snapshot, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        if snapshot?.isEmpty != true && snapshot != nil {
                            
                            self.farmNameArray.removeAll(keepingCapacity: false)
                            self.plantedVegetablesArray.removeAll(keepingCapacity: false)
                            self.plantedDateArray.removeAll(keepingCapacity: false)
                            self.harvestDateArray.removeAll(keepingCapacity: false)
                            self.documentIdArray.removeAll(keepingCapacity: false)
                            
                            
                            for document in snapshot!.documents {
                                let documentID = document.documentID
                                self.documentIdArray.append(documentID)
                                
                                if let farmName = document.get("farmName") as? String {
                                    self.farmNameLabel.text = "Tarla adı: \(farmName)"
                                    self.farmNameArray.append(farmName)
                                }
                                
                                if let plantedVegetables = document.get("plantedVegetables") as? String {
                                    self.plantedVegetablesLabel.text = "Ekilen Ürün: \(plantedVegetables)"
                                    self.plantedVegetablesArray.append(plantedVegetables)
                                }
                                
                                if let plantedDate = document.get("plantedDate") as? String {
                                    self.plantedDateLabel.text = "Ekilen Tarih: \(plantedDate)"
                                    self.plantedDateArray.append(plantedDate)
                                }
                                
                                if let harvestDate = document.get("harvestDateText") as? String {
                                    self.harvestDateLabel.text = "Hasat Edilecek Tarih: \(harvestDate)"
                                    self.harvestDateArray.append(harvestDate)
                                }
                                
                                if let placeLatitude = document.get("latitude") as? String {
                                    if let placeLatitudeDouble = Double(placeLatitude) {
                                        self.chosenLatitude = placeLatitudeDouble
                                    }
                                }
                                
                                if let placeLongitude = document.get("longitude") as? String {
                                    if let placeLongitudeDouble = Double(placeLongitude) {
                                        self.chosenLongitude = placeLongitudeDouble
                                    }
                                }
                                
                                let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                                
                                let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                                
                                let region = MKCoordinateRegion(center: location, span: span)
                                
                                self.detailsMapView.setRegion(region, animated: true)
                                
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = location
                                annotation.title = self.farmNameLabel.text!
                                self.detailsMapView.addAnnotation(annotation)
                                
                            }
                        }
                    }
                }
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
        
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if self.chosenLongitude != 0.0 && self.chosenLatitude != 0.0 {
                let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                
                CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                    if let placemark = placemarks {
                        
                        if placemark.count > 0 {
                            
                            let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                            let mapItem = MKMapItem(placemark: mkPlaceMark)
                            mapItem.name = self.farmNameLabel.text
                            
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                            
                            mapItem.openInMaps(launchOptions: launchOptions)
                        }
                        
                    }
                }
                
            }
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
