//
//  CartItem.swift
//  MyStore
//
//  Created by souvik_roy on 19/07/24.
//

import Foundation

struct CartItem: Codable{
    let id: Int
    let name: String
    let price: String
    let imageName: String
    var quantity: Int
    
    init(id: Int, name: String, price: String, imageName: String, quantity: Int = 1) {
           self.id = id
           self.name = name
           self.price = price
           self.imageName = imageName
           self.quantity = quantity
       }
}
