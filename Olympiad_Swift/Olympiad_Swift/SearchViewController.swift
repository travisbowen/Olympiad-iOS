//
//  SearchViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 11/29/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import CoreLocation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var firebase: FIRDatabaseReference!
    var cellId = "cellId"
    var userList = [User]()
    var ageList = [User]()
    var genderList = [User]()
    var reasonList = [User]()
    var skillList = [User]()
    var signedUserAge : String!
    var signedUserGender : String!
    var signedUserReason : String!
    var signedUserSkill : String!
    var signedUserEmail : String!
    var selectedEmail   : String!
    var signedUserLatitude : String!
    var signedUserLongitude : String!
    var currentUserLatitude : Double!
    var currentUserLongitude : Double!
    var returnCount = 0
    var userAverage : Double! = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1143273463088335/2290586000"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        //Firebase reference
        firebase = FIRDatabase.database().reference()
        
        //Custom method pulling signed user's info
        fetchSignedInUser()
    }
    
    
    //Custom method to retrieve signed in user's information
    func fetchSignedInUser(){
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // Load User Info
        firebase.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.signedUserAge = (value?["age"] as? String)!
            self.signedUserGender = (value?["gender"] as? String)!
            self.signedUserReason = (value?["reason"] as? String)!
            self.signedUserSkill = (value?["skill"] as? String)!
            self.signedUserSkill = (value?["email"] as? String)!
            self.currentUserLatitude = (value?["latitude"] as? Double)!
            self.currentUserLongitude = (value?["longitude"] as? Double)!
        })
        
        //Custom method pulling users
        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    //Custom method to retrieve users information
    func fetchUsers(){
        
        firebase.child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary{
                
                let user = User()
                
                //user.setValuesForKeys(dictionary)
                user.name = (dictionary["name"] as? String)!
                user.gender = (dictionary["gender"] as? String)!
                user.age = (dictionary["age"] as? String)!
                user.email = (dictionary["email"] as? String)!
                user.average = (dictionary["average"] as? Double)!
                user.location = (dictionary["location"] as? String)!
                user.latitude = (dictionary["latitude"] as? Double)!
                user.longitude = (dictionary["longitude"] as? Double)!
                user.reason = (dictionary["reason"] as? String)!
                user.skill = (dictionary["skill"] as? String)!
                user.image = (dictionary["image"] as? String)!
                user.motivation = (dictionary["motivation"] as? String)!
                user.workout = (dictionary["time"] as? String)!
                
                let currentUserLocation = CLLocation(latitude: self.currentUserLatitude!, longitude: self.currentUserLongitude!)
                let foundUserLocation = CLLocation(latitude: user.latitude!, longitude: user.longitude!)
                
                let distance : Double = (currentUserLocation.distance(from: foundUserLocation)/1000*0.62137119)
                
                user.distance = distance
                
                if user.email != self.signedUserEmail { self.userList.append(user) }
                
                self.userList.sort {$0.distance! < $1.distance!}
                
                print(self.userList.distance)
                
                if self.signedUserAge == user.age{
                    if user.email != self.signedUserEmail { self.ageList.append(user) }
                    self.ageList.sort {$0.distance! < $1.distance!}
                }
                
                if self.signedUserGender == user.gender{
                    if user.email != self.signedUserEmail { self.genderList.append(user) }
                    self.genderList.sort {$0.distance! < $1.distance!}
                }
    
                if self.signedUserReason == user.reason{
                    if user.email != self.signedUserEmail { self.reasonList.append(user) }
                    self.reasonList.sort {$0.distance! < $1.distance!}
                }
                
                if self.signedUserSkill == user.skill{
                    if user.email != self.signedUserEmail { self.skillList.append(user) }
                    self.skillList.sort {$0.distance! < $1.distance!}
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TableViewCell
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        //Setting user image settings
        setImageSettings(cell: cell)
        
        switch segmentedControl.selectedSegmentIndex  {
            
        case 0:
            let user = ageList[indexPath.row]
            
            cell.userNameLabel.text = user.name
            cell.userInfoLabel.text = user.gender! + "-" + user.age!
            cell.userLocationLabel.text = user.location
            cell.userDistanceLabel.text = "\(String(format: "%.2f", user.distance!)) miles away"
            cell.userRatingLabel.text = "\(user.average!)"
            
            if user.image != "" {
                let imageURL = NSURL(string: user.image!)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                cell.userImage.image = profileImage
            }
            
        case 1:
            let user = genderList[indexPath.row]
            
            cell.userNameLabel.text = user.name
            cell.userInfoLabel.text = user.gender! + "-" + user.age!
            cell.userLocationLabel.text = user.location
            cell.userDistanceLabel.text = "\(String(format: "%.2f", user.distance!)) miles away"
            cell.userRatingLabel.text = "\(user.average!)"
            
            if user.image != "" {
                let imageURL = NSURL(string: user.image!)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                cell.userImage.image = profileImage
            }
            
        case 2:
            let user = reasonList[indexPath.row]
            
            cell.userNameLabel.text = user.name
            cell.userInfoLabel.text = user.gender! + "-" + user.age!
            cell.userLocationLabel.text = user.location
            cell.userDistanceLabel.text = "\(String(format: "%.2f", user.distance!)) miles away"
            cell.userRatingLabel.text = "\(user.average!)"
            
            if user.image != "" {
                let imageURL = NSURL(string: user.image!)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                cell.userImage.image = profileImage
            }
            
        case 3:
            let user = skillList[indexPath.row]
            
            cell.userNameLabel.text = user.name
            cell.userInfoLabel.text = user.gender! + "-" + user.age!
            cell.userLocationLabel.text = user.location
            cell.userDistanceLabel.text = "\(String(format: "%.2f", user.distance!)) miles away"
            cell.userRatingLabel.text = "\(user.average!)"
            
            if user.image != "" {
                let imageURL = NSURL(string: user.image!)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                cell.userImage.image = profileImage
            }
            
        default:
            let user = userList[indexPath.row]
            
            cell.userNameLabel.text = user.name
            cell.userInfoLabel.text = user.gender! + "-" + user.age!
            cell.userLocationLabel.text = user.location
            cell.userDistanceLabel.text = "\(String(format: "%.2f", user.distance!)) miles away"
            cell.userRatingLabel.text = "\(user.average!)"
            
            if user.image != "" {
                let imageURL = NSURL(string: user.image!)
                let imageData = NSData(contentsOf:imageURL as! URL)
                let profileImage = UIImage(data: imageData as! Data)
                cell.userImage.image = profileImage
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
            
        case 0:
            returnCount = ageList.count
            break
        case 1:
            returnCount = genderList.count
            break
        case 2:
            returnCount = reasonList.count
            break
        case 3:
            returnCount = skillList.count
            break
        default:
            returnCount = userList.count
            break
        }
        return returnCount
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userVC = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        userVC.userInfoObject = userList[indexPath.item]
        self.navigationController?.show(userVC, sender: self)
    }
    
    
    func setImageSettings(cell : TableViewCell){
        
        cell.userImage.layer.borderWidth=1.0
        cell.userImage.layer.masksToBounds = false
        cell.userImage.layer.cornerRadius = 13
        cell.userImage.layer.borderColor = UIColor.white.cgColor
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.height/2
        cell.userImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
