//
//  FollowersViewModel.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import Foundation

class FollowersViewModel {
    
    private var followersFromUser: String!
    
    private var isLoading: Bool = false {
        didSet {
            self.updateLoadingClosure?(self.isLoading)
        }
    }
    
    private var followers:[User] = [User]() {
        didSet {
            self.updateFollowersCountClosure?()
        }
    }
    
    var followersCount:Int {
        get {
            return self.followers.count
        }
    }
    
    var alertMessage:String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var updateFollowersCountClosure : (()->())?
    var showAlertClosure : (()->())?
    var updateLoadingClosure : ((Bool) -> ())?
    
    init(from userLogin:String?) {
        followersFromUser = userLogin ?? ""
    }
    
    func fetchFollowers() {
        isLoading = true
        APIService.instance.loadFolowers(for: followersFromUser, success: { followers in
            if followers.count > 0 {
                self.followers += followers
            } else {
                self.alertMessage = "No more users."
            }
            self.isLoading = false
        }) { error in
            self.alertMessage = error.rawValue
            self.isLoading = false
        }
    }
    
    func getFollower(for index:Int) -> User {
        return followers[index]
    }
    
}
