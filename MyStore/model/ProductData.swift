//
//  ProductData.swift
//  MyStore
//
//  Created by souvik_roy on 10/07/24.
//

import Foundation
import UIKit
 
struct ProductModel: Codable{
    var response: [Product]?
}
 
struct Product: Codable {
    var categoryName: String
    var products: [ProductDetails]?
}
 
struct ProductDetails: Codable {
    var id: Int
    var name: String
    var imageName: String
    var price: String
    var description: String
    var rating: String
//    var categoryName: String 

}
