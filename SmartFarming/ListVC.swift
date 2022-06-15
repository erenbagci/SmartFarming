//
//  ListVC.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 15.06.2022.
//

import UIKit
import Firebase

class ListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))
        
    }
    
    @objc func addButtonClicked() {
        //Segue
    }
    
    @objc func logoutButtonClicked() {
        do {
                   try  Auth.auth().signOut()
                   self.performSegue(withIdentifier: "homeToLogin", sender: nil)
               } catch {
                   print("error")
               }
           }
    
}
  


