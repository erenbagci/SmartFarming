//
//  ListVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 15.06.2022.
//

import UIKit
import Firebase

class ListVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var placeNameArray = [String]()
    var documentIdArray = [String]()

    var selectedPlaceId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))

        // Do any additional setup after loading the view.
        
        getDataFromFirestore()
    }
    
    func getDataFromFirestore() {
        
        let fireStoreDatabase = Firestore.firestore()
        
        /*let settings = fireStoreDatabase.settings
         settings.areTimestampsInSnapshotsEnabled = true
         fireStoreDatabase.settings = settings
         */
        
        let farmRef = fireStoreDatabase.collection("Farm")
        let userEmail = FarmModel.sharedInstance.currentUserEmail

        
        farmRef.whereField("farmerBy", isEqualTo: userEmail).order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.placeNameArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        
                        if let farmName = document.get("farmName") as? String{
                            self.placeNameArray.append(farmName)
                        }
                    }
                    self.tableView.reloadData()
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
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        selectedPlaceId = documentIdArray[indexPath.row]
        self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FarmTableViewCell", for: indexPath) as! FarmTableViewCell
        cell.configUI(farmName: placeNameArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNameArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPlaceId = selectedPlaceId
        }
    }
}



