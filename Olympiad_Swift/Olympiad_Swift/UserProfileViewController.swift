//
//  UserProfileViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/2/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

 
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userGenderAge: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userSkill: UILabel!
    @IBOutlet weak var userMotivation: UILabel!
    @IBOutlet weak var userReason: UILabel!
    @IBOutlet weak var userWorkoutTime: UILabel!
    @IBOutlet weak var userMessage: UIButton!

    
    var userInfoObject : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = userInfoObject?.name
        userGenderAge.text = userInfoObject?.gender
        userLocation.text = userInfoObject?.location
        userSkill.text = userInfoObject?.skill
        userMotivation.text = userInfoObject?.motivation
        userReason.text = userInfoObject?.reason
        userWorkoutTime.text = userInfoObject?.workout
        
        
        let imageURL = NSURL(string: (userInfoObject?.image)!)
        let imageData = NSData(contentsOf:imageURL as! URL)
        let profileImage = UIImage(data: imageData as! Data)
        userImage.image = profileImage
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
