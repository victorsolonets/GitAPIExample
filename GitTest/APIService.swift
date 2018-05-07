//
//  APIService.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import Foundation
import Alamofire

typealias complitionDictSuccess = ([User]) -> ()
typealias complitionFailed = (APIError) -> ()

public var baseURLConnection = "https://api.github.com/users"

enum APIError: String, Error {
    case noNetwork = "No network"
    case serverOverload = "Server is overloaded."
    case permissionDenied = "Timeout request."
}

class APIService: URLSession {
    
    public var isNetworkReachability = false
    
    public var manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default
        )
        manager.session.configuration.timeoutIntervalForRequest = 30.0
        return manager
    }()
    
    fileprivate var session:SessionManager!
    
    static let instance : APIService = {
        let instance = APIService()
        
        return instance
    }()
    
    public func loadUsers(from since: Int, to perPage:Int, success: @escaping complitionDictSuccess, failed:@escaping complitionFailed) {
    
        let endpoint = baseURLConnection
        
        let parameters:Parameters = ["since" : since.description,
                                     "per_page" : perPage.description]
        
        manager.request(endpoint, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { responseData in
                guard let result = responseData.result.value as? [[String:Any]] else {
                    failed(.serverOverload)
                    return
                }
                let users = self.parseUsersInfo(array: result)
                success(users)
        }
        
    }
    
    public func loadFolowers(for login: String, success: @escaping complitionDictSuccess, failed:@escaping complitionFailed) {
        let endpoint = "\(baseURLConnection)/\(login)/followers"
        
        manager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { responseData in
                guard let result = responseData.result.value as? [[String:Any]] else {
                    failed(.serverOverload)
                    return
                }
                let users = self.parseUsersInfo(array: result)
                success(users)
        }
    }
    
    private func parseUsersInfo(array:[[String:Any]]) -> [User] {
        var users = [User]()
        for item in array {
            let strJSONData = self.convertToJSON(dict: item).data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                var user = try decoder.decode(User.self, from: strJSONData)
                user.repos_url = "https://github.com/\(user.login ?? "")"
                users.append(user)
            } catch let error {
                print("error \(error)")
            }
        }
        return users
    }
    
    private func convertToJSON(dict:[String:Any]) -> String {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            let theJSONText = String(data: theJSONData, encoding: .utf8)
            return theJSONText!
        } else {
            return ""
        }
    }

}
