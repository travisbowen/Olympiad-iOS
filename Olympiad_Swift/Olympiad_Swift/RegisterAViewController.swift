//
//  Olympiad by Travis B. & Tony K.
//
//  Copyright © 2016 UpscaleApps. All rights reserved.
//
// ###################### VIEW NOTES ######################
// - View is used for both Signup And Edit Views for Part A
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class RegisterAViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate,
UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // View Outlets
    @IBOutlet weak var inputUserImage    : UIImageView!
    @IBOutlet weak var inputUserName     : UITextField!
    @IBOutlet weak var inputUserGender   : UITextField!
    @IBOutlet weak var inputUserAge      : UITextField!
    @IBOutlet weak var inputUserLocation : UITextField!
    @IBOutlet weak var pickerTextView    : UIPickerView!
    @IBOutlet weak var menuItemBack      : UIMenuItem!
    var firebase: FIRDatabaseReference!
    
    // View Variables
    var arrayGenders : [String] = ["Male", "Female", "Other"]
    var profileImage : UIImage!
    
    // View Actions
    @IBAction func buttonNextInfo (_ sender: UIButton) {
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
    
    // Update Profile info
    func updateProfile (userID : String) {
        
        // Reason, Time, Skill, Motivation -> Update
        self.firebase.child("users").child(userID)
            .updateChildValues(["name": self.inputUserName.text!,
                                "age": self.inputUserAge.text!,
                                "gender": self.inputUserGender.text!,
                                "location": self.inputUserLocation.text!])
        
        self.performSegue(withIdentifier: "nextRegPush", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Variables
        firebase = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        // Delegates
        inputUserGender.delegate   = self
        // Profile Image View on Tap -> Select Photo
        self.inputUserImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
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
