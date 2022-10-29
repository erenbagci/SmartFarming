//
//  DetailsVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 17.06.2022.
//

import UIKit
import MapKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

enum DetailsScreenMode {
    case editing
    case normal
}

class DetailsVC: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var farmNameText: UITextField!
    @IBOutlet weak var plantedVegetablesText: UITextField!
    @IBOutlet weak var plantedDateText: UITextField!
    @IBOutlet weak var harvestDateText: UITextField!
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var detailsMapView: MKMapView!
    var chosenPlaceId = ""
    var screenMode: DetailsScreenMode = .normal
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        createDatePicker2()
        getDataFromFirestore()
        detailsMapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(updateButtonClicked))
        
    }
    
    fileprivate func configScreenForNormalMode() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(updateButtonClicked))
        
        farmNameText.isUserInteractionEnabled = false
        plantedVegetablesText.isUserInteractionEnabled = false
        plantedDateText.isUserInteractionEnabled = false
        harvestDateText.isUserInteractionEnabled = false
        saveData()
    }
    
    fileprivate func configScreenForEditingMode() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(updateButtonClicked))
        
        // TODO: haritadam lat lng seçtir
        farmNameText.text = ""
        plantedVegetablesText.text = ""
        plantedDateText.text = ""
        harvestDateText.text = ""
        farmNameText.isUserInteractionEnabled = true
        plantedVegetablesText.isUserInteractionEnabled = true
        plantedDateText.isUserInteractionEnabled = true
        harvestDateText.isUserInteractionEnabled = true
    }
    
    @objc func updateButtonClicked() {
        if screenMode == .normal {
            screenMode = .editing
            configScreenForEditingMode()
        } else {
            screenMode = .normal
            configScreenForNormalMode()
        }
    }
    
    func saveData() {
        let fireStoreDatabase = Firestore.firestore()
        
        let farmRef = fireStoreDatabase.collection("Farm").document(chosenPlaceId)
        
        if let farmNameText = farmNameText.text, let plantedVegetablesText = plantedVegetablesText.text, let plantedDateText = plantedDateText.text, let harvestDateText = harvestDateText.text {
            farmRef.updateData(["farmName": farmNameText,
                                "plantedVegetables": plantedVegetablesText,
                                "plantedDate": plantedDateText,
                                "harvestDateText":  harvestDateText,
                                "latitude": chosenLatitude,
                                "longitude": chosenLongitude]) { (error) in
                if error == nil {
                    // TODO: makeAlert
                    print("updated")
                } else{
                    // TODO: makeAlert

                    print("not updated")
                }
            }
            
        }
    }
    
    func getDataFromFirestore() {
        let fireStoreDatabase = Firestore.firestore()
        
        fireStoreDatabase.collection("Farm").document(chosenPlaceId).addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let documentID = document.documentID
                
                if let farmName = document.get("farmName") as? String {
                    self.farmNameText.text = "Tarla adı: \(farmName)"
                }
                
                if let plantedVegetables = document.get("plantedVegetables") as? String {
                    self.plantedVegetablesText.text = "Ekilen Ürün: \(plantedVegetables)"
                }
                
                if let plantedDate = document.get("plantedDate") as? String {
                    self.plantedDateText.text = "Ekilen Tarih: \(plantedDate)"
                }
                
                if let harvestDate = document.get("harvestDateText") as? String {
                    self.harvestDateText.text = "Hasat Edilecek Tarih: \(harvestDate)"
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
                
                self.addAnnotation()
                
            } else {
                // TODO: makeAlert
                print("Document does not exist")
            }
        }
    }
    
    fileprivate func addAnnotation() {
        let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.detailsMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = self.farmNameText.text!
        self.detailsMapView.addAnnotation(annotation)
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
                        mapItem.name = self.farmNameText.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                    
                }
            }
            
        }
    }
    
    func createDatePicker() {
        
        //DatePicker'da oluşan tarihi textfield'a kaydetmek için kullancağımız butonu koyacağımız barı oluşturuyoruz.
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //Barda bulunacak butonu oluşturduk.
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneButtonClicked))
        toolbar.setItems([doneButton], animated: true)
        
        //inputAccessoryView : Text field için sistem tarafından sunulan klavyeye aksesuar görünümü eklemek için kullanıyoruz. Bizde butonumuz için bir toolbar ekliyoruz.
        plantedDateText.inputAccessoryView = toolbar
        
        //inputAccessoryView : Text field için sistem tarafından sunulan klavyenin yerini alacak bir görünüm eklemek için kullanıyoruz. Bizde klavye yerine datePicker kullanıyoruz.
        plantedDateText.inputView = datePicker
        
        //DatePicker'ımızın modunu belirliyor. Tarih, saat, zamanlayıcı gibi.
        datePicker.datePickerMode = .date
    }
    @objc func doneButtonClicked() {
        
        //Yazdıracağımız tarihin formatını belirliyoruz.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        //Text field'a date picker'dan gelen değeri yazdırıyoruz.
        plantedDateText.text = formatter.string(from: datePicker.date)
        
        //Done butonuna bastıktan sonra klavyemizin kapanacağını söylüyruz.
        self.view.endEditing(true)
    }
    
    
    
    func createDatePicker2() {
        
        //DatePicker'da oluşan tarihi textfield'a kaydetmek için kullancağımız butonu koyacağımız barı oluşturuyoruz.
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        
        //Barda bulunacak butonu oluşturduk.
        let doneButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneButtonClicked2))
        toolbar2.setItems([doneButton2], animated: true)
        
        //inputAccessoryView : Text field için sistem tarafından sunulan klavyeye aksesuar görünümü eklemek için kullanıyoruz. Bizde butonumuz için bir toolbar ekliyoruz.
        harvestDateText.inputAccessoryView = toolbar2
        
        //inputAccessoryView : Text field için sistem tarafından sunulan klavyenin yerini alacak bir görünüm eklemek için kullanıyoruz. Bizde klavye yerine datePicker kullanıyoruz.
        harvestDateText.inputView = datePicker
        
        //DatePicker'ımızın modunu belirliyor. Tarih, saat, zamanlayıcı gibi.
        datePicker.datePickerMode = .date
    }
    @objc func doneButtonClicked2() {
        
        //Yazdıracağımız tarihin formatını belirliyoruz.
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .medium
        formatter2.timeStyle = .none
        
        //Text field'a date picker'dan gelen değeri yazdırıyoruz.
        harvestDateText.text = formatter2.string(from: datePicker.date)
        
        //Done butonuna bastıktan sonra klavyemizin kapanacağını söylüyruz.
        self.view.endEditing(true)
    }
    
    
}
