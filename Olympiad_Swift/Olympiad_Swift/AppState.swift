//
//  AppState.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/13/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
}
