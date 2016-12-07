//
//  Message.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/6/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var senderId: String?
    var toId: String?
    var text: String?
    var timeStamp: NSNumber?
    
    func chatPartnerId() -> String? {
        if senderId == FIRAuth.auth()?.currentUser?.uid {
            return toId!
        } else {
            return senderId!
        }
    }
}
