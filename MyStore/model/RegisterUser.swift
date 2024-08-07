//
//  User.swift
//  MyStore
//
//  Created by souvik_roy on 11/07/24.
//

import Foundation

struct RegisterUser: Codable{
    var name: String
    var email: String
    var password: String
    var userId: String
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = ""
        self.userId = UUID().uuidString // generate a UUID for userID
    }
    
}
