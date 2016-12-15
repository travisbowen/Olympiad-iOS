//
//  ChatViewController.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/13/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds


class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

   
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var clientTable: UITableView!
    fileprivate var _refHandle: FIRDatabaseHandle!
    
    var ref: FIRDatabaseReference!
    var messages: [FIRDataSnapshot]! = []
    var msglength: NSNumber = 50
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clientTable.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        
        configureDatabase()
    }
    
    
    
    @IBAction func didSendMessage(_ sender: UIButton) {
        textFieldShouldReturn(textField)
    }
    
//    
//    deinit {
//        self.ref.child("messages").removeObserver(withHandle: _refHandle)
//    }
//    
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("messages").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.messages.append(snapshot)
            strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
            self?.clientTable.reloadData()
        })
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= self.msglength.intValue // Bool
    }
    
    
    // UITableViewDataSource protocol methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.clientTable .dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        // Unpack message from Firebase DataSnapshot
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        print(message)
        let name = message[Constants.MessageFields.name] as String!
        let text = message[Constants.MessageFields.text] as String!
        cell.textLabel?.text = name! + ": " + text!
        cell.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoURL = message[Constants.MessageFields.photoURL], let URL = URL(string: photoURL), let data = try? Data(contentsOf: URL) {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }
    
    
    // UITextViewDelegate protocol methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        textField.text = ""
        view.endEditing(true)
        let data = [Constants.MessageFields.text: text]
        sendMessage(withData: data)
        return true
    }
    
    
    func sendMessage(withData data: [String: String]) {
        var mdata = data
        mdata[Constants.MessageFields.name] = AppState.sharedInstance.displayName
        if let photoURL = AppState.sharedInstance.photoURL {
            mdata[Constants.MessageFields.photoURL] = photoURL.absoluteString
        }
        // Push data to Firebase Database
        self.ref.child("messages").childByAutoId().setValue(mdata)
    }

}
