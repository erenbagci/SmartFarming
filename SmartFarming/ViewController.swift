//
//  ViewController.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 14.06.2022.
//

import UIKit
import Firebase
import JSSAlertView
import Lottie


class ViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var animationView: AnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailText.text = "qwe@gmail.com"
        passwordText.text = "123456"
         
//
        // 1. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 2. Set animation loop mode
        
        animationView.loopMode = .loop
        
        // 3. Adjust animation speed
        
        animationView.animationSpeed = 0.5
        
        // 4. Play animation
        animationView.play()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    @IBAction func signInClicked(_ sender: Any) {
        
        
        if let email = emailText.text, let password = passwordText.text {
            Auth.auth().signIn(withEmail: email, password: password) { authdata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error",responseType: .error)
                }else {
                    self.performSegue(withIdentifier: "toListVC", sender: nil)
                    //singletondaki mevcut hesabın güncellenmesi
                    FarmGlobal.sharedInstance.currentUserEmail = email
                  }
            }
        }else {
            makeAlert(titleInput: "Error!", messageInput: "Username/Pssword?",responseType: .error)
        }
    }
         
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignUpVC", sender: nil)

        
        
               /* if let email = emailText.text,let password = passwordText.text {
                   Auth.auth().createUser(withEmail: email, password: password
                   ) { authdata, error in
                       if error != nil {
                           self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error", responseType: .error)
                           
                       } else {
                           self.makeAlert(titleInput: "Kullanıcı oluşturuldu", messageInput:"Başarılı",responseType: .success)                       }
                   }
               } else {
                   makeAlert(titleInput: " Error!", messageInput: "Username/Password",responseType: .error)
               }
               */
           }
            
    
    func makeAlert(titleInput:String, messageInput:String, responseType:ServiceResponseType) {
//        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
//        let okButton = UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil)
//        alert.addAction(okButton)
//        self.present(alert, animated: true, completion: nil)
//
        let color: UIColor = responseType == .success ? .green : .red
        
        JSSAlertView().show(
            self,
            title: titleInput,
            text: messageInput,
            buttonText: "OK!",
            color: color)
    }
}

