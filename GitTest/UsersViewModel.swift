//
//  UsersViewModel.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import Foundation

class UsersViewModel {

    private var isLoading: Bool = false {
        didSet {
            self.updateLoadingClosure?(self.isLoading)
        }
    }
    
    private var users:[User] = [User]() {
        didSet {
            self.updateUsersCountClosure?()
        }
    }
    
    private var pageCount = 100
    private var lastLoadIndex = 0
    
    var usersCount:Int {
        get {
            return self.users.count
        }
    }
    
    var alertMessage:String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var updateUsersCountClosure : (()->())?
    var showAlertClosure : (()->())?
    var updateLoadingClosure : ((Bool) -> ())?
    
    func fetchMoreUsers() {
        isLoading = true
        APIService.instance.loadUsers(from: lastLoadIndex, to: pageCount, success: { users in
            if users.count > 0 {
                self.users += users
            } else {
                self.lastLoadIndex = 0
                self.alertMessage = "No more users."
            }
            self.isLoading = false
        }) { error in
            self.alertMessage = error.rawValue
            self.isLoading = false
            self.lastLoadIndex -= self.pageCount
        }
        lastLoadIndex += pageCount
    }
    
    func getUser(for index:Int) -> User {
        return users[index]
    }
    
}
