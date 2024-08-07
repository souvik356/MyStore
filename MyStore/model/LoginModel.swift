//
//  LoginModel.swift
//  MyStore
//
//  Created by souvik_roy on 15/07/24.
//

import Foundation

struct LoginModel{
    let email: String
    let password: String
    
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
}
