//
//  Olympiad by Travis B. & Tony K.
//
//  Copyright © 2016 UpscaleApps. All rights reserved.
//
// ###################### VIEW NOTES ######################
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import GoogleMobileAds

class EditBViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UITabBarDelegate,
                            UINavigationControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate {
    
    // View Outlets
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var inputUserImage   : UIImageView!
    @IBOutlet weak var inputAppReason   : UITextField!
    @IBOutlet weak var inputWorkoutTime : UITextField!
    @IBOutlet weak var inputMotivation  : UITextField!
    @IBOutlet weak var inputSkillLevel  : UITextField!
    @IBOutlet weak var pickerTextView   : UIPickerView!
    @IBOutlet weak var menuItemBack     : UIMenuItem!
    @IBOutlet weak var buttonSaveInfo   : UIButton!
    @IBOutlet weak var labelError        : UILabel!
    
    // View Variables
    var arrayMotivationLevels : [String] = ["Low", "Average", "High"]
    var arraySkillLevels      : [String] = ["Beginner", "Intermediat", "Expert"]
    var arrayWorkoutTimes     : [String] = ["Morning", "Noon", "Afternoon", "Evening"]
    var arrayAppReasons       : [String] = ["Martial Arts", "Weightlifting", "Swimming",
                                            "Running", "Weight Loss", "Hiking", "Sports",
                                            "Commuting to Gym", "Going to Events"]
    var inputTag              : Int      = 0   // For Switch Statement
    var arraySeleted          : [String] = []
    
    var firebase: FIRDatabaseReference!
    var profileImage : UIImage!
    
    // View Actions
    @IBAction func buttonSaveInfo (_ sender: UIButton) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        if inputUserImage.image == nil ||
            inputWorkoutTime.text == "" ||
            inputMotivation.text == "" ||
            inputAppReason.text == "" ||
            inputSkillLevel.text == "" {
            labelError.text = "Please enter in all fields."
            labelError.isHidden = false
        } else {
            // Upload Image
            labelError.isHidden = true
            // Upload Image
            let imageUID = NSUUID().uuidString
            let storage = FIRStorage.storage().reference().child("Profile Images").child("\(imageUID)")
            
            if let imageUpload = UIImagePNGRepresentation(self.inputUserImage.image!) {
                storage.put(imageUpload, metadata: nil,
                            completion: { (metadata, error) in
                                if error != nil {
                                    print(error as! String)
                                    return
                                }
                                // Update Profile Image with URL
                                if let imageURL = metadata?.downloadURL()?.absoluteString {
                                    self.firebase.child("users").child(userID!)
                                        .updateChildValues(["image": imageURL])
                                    self.updateProfile(userID: userID!)
                                }
                })
            } else {
                self.updateProfile(userID: userID!)
            }
        }
    }
    
    // Update Profile info
    func updateProfile (userID : String) {
    
        // Reason, Time, Skill, Motivation -> Update
        self.firebase.child("users").child(userID)
            .updateChildValues(["reason": self.inputAppReason.text!,
                                "time": self.inputWorkoutTime.text!,
                                "skill": self.inputSkillLevel.text!,
                                "motivation": self.inputMotivation.text!])
        
        self.performSegue(withIdentifier: "saveEditPush", sender: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1143273463088335/2290586000"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        
        // Variables
        firebase = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        // Delegates
        inputAppReason.delegate   = self
        inputWorkoutTime.delegate = self
        inputMotivation.delegate  = self
        inputSkillLevel.delegate  = self
        // View Tasks
        // Load User if avaiable
        self.firebase.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.inputAppReason.text = value?["reason"] as? String
            self.inputWorkoutTime.text = value?["time"] as? String
            self.inputSkillLevel.text = value?["skill"] as? String
            self.inputMotivation.text = value?["motivation"] as? String
            
            if value?["image"] as? String != "" {
            let imageURL = NSURL(string: value?["image"] as! String)
            let imageData = NSData(contentsOf:imageURL as! URL)
            let profileImage = UIImage(data: imageData as! Data)
            self.inputUserImage.image = profileImage
            }
        })
        
        // Profile Image View on Tap -> Select Photo
        self.inputUserImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoOrCameraAlert)))
    }

    func photoOrCameraAlert() {
        let alert = UIAlertController(title: "Upload Image", message: "Select Source", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action: UIAlertAction!) in
            self.takeImage()
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction!) in
            self.selectImage()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    // Present Image Picker
    func selectImage () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated:true, completion:nil)
    }
    // Present Camera
    func takeImage () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.showsCameraControls = true
        imagePicker.allowsEditing = true
        present(imagePicker, animated:true, completion:nil)
    }

    
    // Select Image to Upload
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var selected: UIImage?
        
        if let edited = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selected = edited
        } else if let original = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selected = original
        }
        
        if selected != nil {
            self.profileImage = selected!
            inputUserImage.image = self.profileImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Image Picker Canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(tabBar.selectedItem?.title! ?? "No Title")
    }
    
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        // Switch for to get Correct Array for selected Input
        switch inputTag {
        case 1:
            // Reasons
            arraySeleted = arrayAppReasons
            return arrayAppReasons.count
        case 2:
            // Workout Time
            arraySeleted = arrayWorkoutTimes
            return arrayWorkoutTimes.count

        case 3:
            // Motivation Level
            arraySeleted = arrayMotivationLevels
            return arrayMotivationLevels.count
        case 4:
            // Skill Level
            arraySeleted = arraySkillLevels
            return arraySkillLevels.count

        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arraySeleted[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let currentTextField = self.view.viewWithTag(inputTag) as? UITextField
        currentTextField?.text = arraySeleted[row]
        pickerTextView.isHidden = true;
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerTextView.isHidden = false     // Show Picker
        textField.resignFirstResponder()    // Disable Keyboard
        inputTag = textField.tag            // Set Tag for Switch
        pickerTextView.delegate   = self    // Setup Picker for Selected Input
        return false
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
}
