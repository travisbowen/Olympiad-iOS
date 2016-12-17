//
//  UserProfileViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/2/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

class UserProfileViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userGenderAge: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userSkill: UILabel!
    @IBOutlet weak var userMotivation: UILabel!
    @IBOutlet weak var userReason: UILabel!
    @IBOutlet weak var userWorkoutTime: UILabel!
    @IBOutlet weak var userMessage: UIButton!
    @IBOutlet weak var rateUser : UISlider!
    @IBOutlet weak var ratingLabel : UILabel!
    @IBOutlet weak var userRating : UILabel!

    var selectedUID : String = ""
    
    @IBAction func ratingSlider(sender: UISlider) {
        
        let value = Int(sender.value)
        userRating.text = String(value)
        
        let userID = FIRAuth.auth()?.currentUser!.uid
        self.firebase.child("users").child(selectedUID).child("rating")
            .child(userID!).setValue(["rating":Double(value)])
        
        setAverage()
        
    }
    
    var userInfoObject : User?
    var firebase: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase = FIRDatabase.database().reference()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1143273463088335/2290586000"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        userName.text = userInfoObject?.name
        userGenderAge.text = userInfoObject?.gender
        userLocation.text = userInfoObject?.location
        userSkill.text = userInfoObject?.skill
        userMotivation.text = userInfoObject?.motivation
        userReason.text = userInfoObject?.reason
        userWorkoutTime.text = userInfoObject?.workout
        userRating.text = "\(userInfoObject!.average!)"
        
        let imageURL = NSURL(string: (userInfoObject?.image)!)
        let imageData = NSData(contentsOf:imageURL as! URL)
        let profileImage = UIImage(data: imageData as! Data)
        userImage.image = profileImage
        
        self.firebase.child("users").queryOrdered(byChild: "email")
            .queryEqual(toValue: userInfoObject?.email)
            .observeSingleEvent(of: .childAdded, with: { (snapshot) in
                self.selectedUID = snapshot.key
            })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAverage() {
        self.firebase.child("users").child(selectedUID).child("rating").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.hasChildren()) {
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    let ratingCount = Double(snapshots.count)
                    var ratingTotal = 0.0
                    for child in snapshots {
                        let value = child.value as? NSDictionary
                        ratingTotal+=value?["rating"] as! Double
                    }
                    let average = round(Double(ratingTotal/ratingCount) * 2) / 2.0
                    self.userRating.text = String(average)
                    self.rateUser.isHidden = true
                    self.ratingLabel.isHidden = false
                    //Save average to user profile
                    self.firebase.child("users").child(self.selectedUID)
                        .updateChildValues(["average":Double(average)])
                }
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
