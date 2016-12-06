//
//  ChatLogViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/5/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatLogViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var firebase: FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    var signedUserName = ""
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebase = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        firebase.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary{
                
                self.userName = (dictionary["name"] as? String)!
                print("Username " + self.userName)
                
                self.senderId = userID
                self.senderDisplayName = self.userName
            }
        })
        messageRef = firebase.child("users").child(userID!).child("messages")
        
        self.senderId = userID
        self.senderDisplayName = ""
        self.observeMessages()
    }
    
    
    //Pulling messages data in
    func observeMessages(){
        messageRef.observe(.childAdded, with: { snapshot in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let MediaType = dictionary["MediaType"] as! String
                let senderId = dictionary["senderId"] as! String
                let senderName = dictionary["senderName"] as! String
                let text = dictionary["text"] as! String
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                self.collectionView.reloadData()
            }
        })
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        print(text)
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text" : text, "senderId" : senderId, "senderName" : senderDisplayName, "MediaType" : "TEXT"]
        newMessage.setValue(messageData)
        
        //Clear text after sending message
        self.finishSendingMessage()
    }
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubble = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId{
            return bubble?.outgoingMessagesBubbleImage(with: .black)
        } else {
            return bubble?.outgoingMessagesBubbleImage(with: .black)
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}


extension ChatLogViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let picture = info[UIImagePickerControllerOriginalImage] as? UIImage
//        let photo = JSQPhotoMediaItem(image: picture!)
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
//        self.dismiss(animated: true, completion: nil)
//        collectionView.reloadData()
//    }
}
