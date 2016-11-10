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
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginButton(_ sender: UIButton) {
        
        if (userEmail.text != "" && userPass.text != "" && (userEmail.text?.contains("@"))! && (userEmail.text?.contains(".com"))!){
            
            //Signing into Firebase
            FIRAuth.auth()?.signIn(withEmail: userEmail.text!, password: userPass.text!) { (user, error) in
                if error == nil {
                    
                    print("User logged in")
//                    FIRAuth.auth()?.addStateDidChangeListener { auth, user in
//                        if user != nil {
//                            // User is signed in.
//                      
//                        } else {
//                            // No user is signed in.
//                        }
//                    }
                } else {
                    print("User not logged in")
                }
            }
        } else {
            print("Email or password not correct")
        }
    }


    @IBAction func signUpButton(_ sender: UIButton) {
        
    }

}

