//
//  ChatLogController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/6/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    var user: User?
    
    let inputTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = user?.name
        
        collectionView?.backgroundColor = UIColor.white
        
        setupMessageComponents()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupMessageComponents() {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)

        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
   
        containerView.addSubview(inputTF)

        inputTF.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTF.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTF.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTF.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    func handleSend() {
        print(inputTF.text!)
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let senderId = FIRAuth.auth()?.currentUser?.uid
        let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputTF.text!, "toId": toId, "senderId": senderId!, "timeStamp": timeStamp] as [String : Any]
//        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(senderId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let receiverUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            receiverUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
}
