//
//  MessagesController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/5/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase


class MessagesController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Messages"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreate))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
//        observeChat()
        observeUsersMessages()
    }
    
    
    func observeUsersMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let toId = message.toId{
                        self.messageDict[toId] = message
                        
                        self.messageList = Array(self.messageDict.values)
                        self.messageList.sort(by: { (message1, message2) -> Bool in
                            
                            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    
    var messageList = [Message]()
    var messageDict = [String: Message]()
    
    func observeChat(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{

                let message = Message()
                message.setValuesForKeys(dictionary)
//                self.messageList.append(message)
//                print(message.text! + "Sweet")
                
                //Adding all of one users messages into messageDict
                if let toId = message.toId{
                    self.messageDict[toId] = message
                    
                    self.messageList = Array(self.messageDict.values)
                    self.messageList.sort(by: { (message1, message2) -> Bool in
                        
                        return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        
        let message = messageList[indexPath.row]
        
        if let toId = message.toId {
            let ref = FIRDatabase.database().reference().child("users").child(toId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    cell.textLabel?.text = dictionary["name"] as? String
                    
                    let image = dictionary["image"] as? String
                    let imageURL = NSURL(string: image! as String)
                    let imageData = NSData(contentsOf:imageURL as! URL)
                    let profileImage = UIImage(data: imageData as! Data)
                        
                    DispatchQueue.main.async {
                        cell.avatarImage.image = profileImage
                    }
                    
                }
            }, withCancel: nil)
        }

        cell.detailTextLabel?.text = message.text!
        
        return cell
    }
    
    
    func handleCreate() {
        let newMessageTableController = NewMessageTableController()
        newMessageTableController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageTableController)
        present(navController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func showChatController(user : User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
