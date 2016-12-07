//
//  NewMessageTableController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/6/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableController: UITableViewController{
    
    var usersList = [User]()
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "Local Users"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
        fetchUser()
    }
    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User()
                
                user.id = snapshot.key
                
                user.name = dictionary["name"] as! String?
                user.location = dictionary["location"] as! String?
                user.image = dictionary["image"] as! String?
                
                self.usersList.append(user)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath as IndexPath) as! UserCell
        
        let user = usersList[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.location
        
        if user.image != "" {
            let imageURL = NSURL(string: user.image! as String)
            let imageData = NSData(contentsOf:imageURL as! URL)
            let profileImage = UIImage(data: imageData as! Data)
            
            DispatchQueue.main.async {
                cell.avatarImage.image = profileImage
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.usersList[indexPath.row]
            self.messagesController?.showChatController(user: user)
        }
    }
}

