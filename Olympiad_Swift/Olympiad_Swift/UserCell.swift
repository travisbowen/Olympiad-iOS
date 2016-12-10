//
//  UserCell.swift
//  Olympiad_Swift
//
//  Created by Travis Bowen on 12/6/16.
//  Copyright © 2016 UpscaleApps. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
        
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 65, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 65, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
        
    let avatarImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
        
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            
        addSubview(avatarImage)
            
        avatarImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        avatarImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        avatarImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
        
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

