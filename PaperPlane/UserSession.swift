//
//  UserSession.swift
//  Sample
//
//  Created by 涂立青 on 2024/8/13.
//

import Foundation

class UserSession {
    static let shared = UserSession()
    
    var accessToken: String?
    var userID: String?
    
    private init() {}
    
    func setUserInfo(accessToken: String, userID: String) {
        self.accessToken = accessToken
        self.userID = userID
    }
    
    func clearUserInfo() {
        accessToken = nil
        userID = nil
    }
}
