//
//  FarmInfoVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 15.06.2022.
//

import UIKit
import MapKit
import Firebase

class FarmInfoVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var farmNameText: UITextField!
    @IBOutlet weak var plantedVegetablesText: UITextField!
    @IBOutlet weak var plantedDateText: UITextField!
    @IBOutlet weak var harvestDateText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let datePicker = UIDatePicker()
    var chosenLatitude = ""
    var chosenLongitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createDatePicker()
        createDatePicker2()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(recognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touches = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = farmNameText.text
            
            self.mapView.addAnnotation(annotation)
            self.chosenLatitude = String(coordinates.latitude)
            self.chosenLongitude = String(coordinates.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("farmInfo")
        
        let firestoreDatabase = Firestore.firestore()
        var firestoreReference : DocumentReference? = nil
        
        // TODO: Boş veri kontrolü yap, makeAlert

        let firestoreFarm = ["farmerBy" : Auth.auth().currentUser!.email as Any, "farmName" : self.farmNameText.text!,"plantedVegetables" : self.plantedVegetablesText.text!,"plantedDate" : self.plantedDateText.text!, "harvestDateText" : self.harvestDateText.text!, "latitude" : self.chosenLatitude, "longitude" : self.chosenLongitude, "date" : FieldValue.serverTimestamp(),] as [String : Any]
        
        firestoreReference = firestoreDatabase.collection("Farm").addDocument(data: firestoreFarm, completion: { (error) in
            if error != nil {
                self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
            } else {
               
                self.performSegue(withIdentifier: "toTableView", sender: nil)

            }
        })
    }
    
    func makeAlert(titleInput:String, messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)


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
