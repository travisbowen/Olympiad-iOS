//
//  Olympiad by Travis B. & Tony K.
//
//  Copyright © 2016 UpscaleApps. All rights reserved.
//
// ###################### VIEW NOTES ######################
//
//

import Foundation
import UIKit
import Firebase

class ProfileViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UITabBarDelegate {
    
    // View Outlets
    @IBOutlet weak var imageUserImage    : UIImageView!
    @IBOutlet weak var labelUserName     : UILabel!
    @IBOutlet weak var labelAgeGender    : UILabel!
    @IBOutlet weak var labelUserLocation : UILabel!
    @IBOutlet weak var labelAppReason    : UILabel!
    @IBOutlet weak var labelWorkoutTime  : UILabel!
    @IBOutlet weak var labelMotivation   : UILabel!
    @IBOutlet weak var labelSkillLevel   : UILabel!
    @IBOutlet weak var menuItemBack      : UIMenuItem!
    @IBOutlet weak var buttonEditInfo    : UIButton!
    // View Variables
    var firebase: FIRDatabaseReference!
    
    override func viewDidLoad() {
        // Variables 
        firebase = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // Tasks
        // Load User Info
        self.firebase.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.labelUserName.text = value?["name"] as? String
            self.labelUserLocation.text = value?["location"] as? String
            self.labelAppReason.text = value?["reason"] as? String
            self.labelMotivation.text = value?["motivation"] as? String
            self.labelSkillLevel.text = value?["skill"] as? String
            self.labelWorkoutTime.text = value?["time"] as? String
            
            if value?["image"] as? String != "" {
                let imageURL = NSURL(string: value?["image"] as! String)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                self.imageUserImage.image = profileImage
            }
            
            if value?["gender"] as? String != "" {
                let gender = value?["gender"] as? String
                let g = gender![(gender?.startIndex)!]
                let age = value?["age"] as! String
                self.labelAgeGender.text = "\(g) - \(age)"
            }
        })
    }
}
