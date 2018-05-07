//
//  UserTableViewCell.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {

    @IBOutlet var loginLabel:UILabel!
    @IBOutlet var urlLabel:UITextView!
    @IBOutlet var avatarImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width/2.0
        self.avatarImage.layer.masksToBounds = true
    }
    
    func configureCell(user:User) {
        loginLabel.text = user.login
        urlLabel.text = user.repos_url
        avatarImage.sd_setImage(with: URL(string:user.avatar_url),
                                placeholderImage: UIImage(),
                                options: SDWebImageOptions.scaleDownLargeImages,
                                completed: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
