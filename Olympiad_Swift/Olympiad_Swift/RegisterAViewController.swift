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
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import GoogleMobileAds

class RegisterAViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate,
    UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
CLLocationManagerDelegate, GADBannerViewDelegate {
    
    // View Outlets
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var inputUserImage    : UIImageView!
    @IBOutlet weak var inputUserName     : UITextField!
    @IBOutlet weak var inputUserGender   : UITextField!
    @IBOutlet weak var inputUserAge      : UITextField!
    @IBOutlet weak var inputUserLocation : UITextField!
    @IBOutlet weak var pickerTextView    : UIPickerView!
    @IBOutlet weak var menuItemBack      : UIMenuItem!
    @IBOutlet weak var labelError        : UILabel!
    var firebase: FIRDatabaseReference!
    
    // View Variables
    var arrayGenders : [String] = ["Male", "Female", "Other"]
    var profileImage : UIImage!
    let locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    // View Actions
    @IBAction func getLocation (_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    @IBAction func buttonNextInfo (_ sender: UIButton) {
        if inputUserImage.image == nil ||
            inputUserName.text == "" ||
            inputUserAge.text == "" ||
            inputUserGender.text == "" ||
            inputUserLocation.text == "" {
            labelError.text = "Please enter in all fields."
            labelError.isHidden = false
        } else {
            labelError.isHidden = true
            let userID = FIRAuth.auth()?.currentUser?.uid
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
            .updateChildValues(["name": self.inputUserName.text!,
                                "age": self.inputUserAge.text!,
                                "gender": self.inputUserGender.text!,
                                "location": self.inputUserLocation.text!,
                                "latitude": self.latitude,
                                "longitude": self.longitude])
        
        self.performSegue(withIdentifier: "nextRegPush", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase = FIRDatabase.database().reference()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1143273463088335/2290586000"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        // Delegates
        inputUserGender.delegate   = self
        
        // Tasks
        self.labelError.isHidden = true
        
        // Profile Image View on Tap -> Select Photo
        self.inputUserImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("Locations: \(locValue.latitude) \(locValue.longitude)")
        let currentLocation = locations[locations.count - 1]
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) {
            (placements, error) -> Void in
            if error != nil {
                print("Location Error")
            }
            
            if let placement = placements?.first {
                self.latitude = locValue.latitude
                self.longitude = locValue.longitude
                self.inputUserLocation.text = ("\(placement.locality!), \(placement.administrativeArea!)")
                self.locationManager.stopUpdatingLocation()
            }
        }
        
    }
    
    
    // Present Image Picker
    func selectImage () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true;
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
    
    // Hides keybaord on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return arrayGenders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayGenders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        inputUserGender.text = arrayGenders[row]
        pickerTextView.isHidden = true;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 9 {
            // Text Field is Gender Picker
            pickerTextView.isHidden = false     // Show Picker
            textField.resignFirstResponder()    // Disable Keyboard
            pickerTextView.delegate   = self    // Delegate Picker
        }
        return false
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
}
