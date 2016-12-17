//
//  ViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 11/5/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
//Import Firebase on every viewcontroller.swift file
import Firebase

class ViewController: UIViewController {
    
    let firebase = FIRDatabase.database().reference()
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check if User has a login
        if (loadUser()) {
            // User Found Move to SelfView
            let saveEmail = UserDefaults.standard.string(forKey: "email")!
            let savePassw = UserDefaults.standard.string(forKey: "password")!
            
            //Signing into Firebase
            FIRAuth.auth()?.signIn(withEmail: saveEmail, password: savePassw) { (user, error) in
                if error == nil {
                    print("User logged in")
                    self.firebase.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let displayName = value?["name"] as? String
                        AppState.sharedInstance.displayName = displayName
                        AppState.sharedInstance.photoURL = user?.photoURL
                        AppState.sharedInstance.signedIn = true
                    })
                    self.performSegue(withIdentifier: "loginPush", sender: nil)
                } else {
                    print(error.debugDescription)
                }
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if (userEmail.text != "" && userPass.text != "" && (userEmail.text?.contains("@"))! && (userEmail.text?.contains(".com"))!){
            
            //Signing into Firebase
            FIRAuth.auth()?.signIn(withEmail: userEmail.text!, password: userPass.text!) { (user, error) in
                if error == nil {
                    print("User logged in")
                    self.firebase.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let displayName = value?["name"] as? String
                        AppState.sharedInstance.displayName = displayName
                        AppState.sharedInstance.photoURL = user?.photoURL
                        AppState.sharedInstance.signedIn = true
                    })
                    // Save Data to skip login screen in future
                    UserDefaults.standard.setValue(self.userEmail.text, forKeyPath: "email")
                    UserDefaults.standard.setValue(self.userPass.text, forKeyPath: "password")
                    UserDefaults.standard.synchronize()
                    self.performSegue(withIdentifier: "loginPush", sender: nil)
                } else {
                    print(error.debugDescription)
                }
            }
        } else {
            print("Email or password not correct")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    func loadUser() -> Bool {
        if ((UserDefaults.standard.value(forKey: "email")) != nil) {
            return true
        }
        return false
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        FIRAuth.auth()?.createUser(withEmail: self.userEmail.text!, password: self.userPass.text!) { (user, error) in
            if (error == nil) {
                // User Signin Success
                self.firebase.child("users").child(user!.uid).setValue([
                    "email": self.userEmail.text!, "name": "",
                    "age": "", "gender": "", "location": "",
                    "latitude": "", "longitude": "",
                    "reason": "", "motivation": "", "skill": "",
                    "time": "", "image": "", "average": 5,
                    "rating":[
                        user!.uid: [
                             "rating": 5.0
                        ]
                    ]
                ])
                // Save Email & Passowrd
                if (self.userEmail.text! != "" && self.userPass.text! != "") {
                    UserDefaults.standard.setValue(self.userEmail.text!, forKeyPath: "email")
                    UserDefaults.standard.setValue(self.userPass.text!, forKeyPath: "password")
                    UserDefaults.standard.synchronize()
                    self.performSegue(withIdentifier: "regPush", sender: nil)
                }
                
            } else {
                // Something Went Wrong
                print(error!.localizedDescription)
            }
        }
    }

}

