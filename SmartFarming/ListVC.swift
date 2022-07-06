//
//  ListVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 15.06.2022.
//

import UIKit
import MapKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class ListVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var placeNameArray = [String]()
    var documentIdArray = [String]()
    var selectedPlaceId = ""
    var filteredFarms: [FarmModel] = []
    var allFarms: [FarmModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //bu fonksiyonu viewDidAppeara al
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getDataFromFirestore()

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))

    }
    
    func getDataFromFirestore() {
        
        let fireStoreDatabase = Firestore.firestore()
        
        let farmRef = fireStoreDatabase.collection("Farm")
        let userEmail = FarmGlobal.sharedInstance.currentUserEmail
        
        
        farmRef.whereField("farmerBy", isEqualTo: userEmail).order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                
                // TODO: makeAlert
                print(error?.localizedDescription)
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    //Array'de datanın tekrar etmemesi için array boşaltılır.
                    self.allFarms.removeAll(keepingCapacity: false)
                    self.filteredFarms.removeAll(keepingCapacity: false)
                    
                    //snapshot içindeki tüm dokümanlar for döngüsünde gezilir.
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        
                        self.allFarms.append(FarmModel(farmName: document.get("farmName") as? String,
                                                       farmLatitude: document.get("latitude") as? String,
                                                       farmLongitude: document.get("longitude") as? String,
                                                       documentId: documentID))
                        
                        
//                        if let farmName = document.get("farmName") as? String,
//                           let latitude = document.get("latitude") as? String,
//                           let longitude = document.get("longitude") as? String {
//                            self.allFarms.append(FarmModel(farmName: farmName, farmLatitude: latitude, farmLongitude: longitude, documentId: documentID))
//                        }
                        
                    }
                    self.filteredFarms = self.allFarms
                    self.tableView.reloadData()
                } else {
                    //TODO: makeAlert hiç tarlanız yok
                }
            }
        }
    }
    
    @objc func addButtonClicked() {
        performSegue(withIdentifier: "farmInfoVC", sender: nil)
    }
    
    @objc func logoutButtonClicked() {
        do {
            try  Auth.auth().signOut()
            self.performSegue(withIdentifier: "homeToLogin", sender: nil)
        } catch {
            
            // TODO: makeAlert
            print("error")
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       filteredFarms = searchText.isEmpty ? allFarms : allFarms.filter {$0.farmName.range(of: searchText, options: .caseInsensitive) != nil}
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        if let documentId = filteredFarms[indexPath.row].documentId {
            selectedPlaceId = documentId
            self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FarmTableViewCell", for: indexPath) as! FarmTableViewCell
        if let farmName = filteredFarms[indexPath.row].farmName {
            cell.configUI(farmName: farmName)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let documentID = filteredFarms[indexPath.row].documentId {
            if (editingStyle == .delete) {
                // handle delete (by removing the data from your array and updating the tableview)
                let fireStoreDatabase = Firestore.firestore()
                
                fireStoreDatabase.collection("Farm").document(documentID).delete() { err in
                    if let err = err {
                        
                        // TODO: makeAlert
                        print("Error removing document: \(err)")
                    } else {
                        //silinen veri arrayin içinde aranır. Yeni index değişkenine atılır ve yeni index arrayden silinir.
                        if let index = self.allFarms.firstIndex(where: {$0.documentId == documentID}) {
                            self.allFarms.remove(at: index)
                        }
                        
                        if let indexFiltered = self.filteredFarms.firstIndex(where: {$0.documentId == documentID}) {
                            self.filteredFarms.remove(at: indexFiltered)
                        }
                        
                        self.tableView.reloadData()

                        // TODO: makeAlert
                        print("Document successfully removed!")
                    }
                }

            }
        }    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFarms.count
    }
    
    @IBAction func mapDetailsButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "mapDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPlaceId = selectedPlaceId
        } else if segue.identifier == "mapDetails" {
            let destinationVC = segue.destination as! MapDetailsViewController
            destinationVC.allFarms = allFarms
        }
    }
}



