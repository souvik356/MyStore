//
//  ProductManager.swift
//  MyStore
//
//  Created by souvik_roy on 23/07/24.
//

import Foundation

class ProductManager {
    static let shared = ProductManager()
    private init() {}
    
    var categories: [Product] = []
    
    func loadProducts() {
        if let url = Bundle.main.url(forResource: "EcommerceJson", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let productResponse = try JSONDecoder().decode(ProductModel.self, from: data)
                self.categories = productResponse.response ?? []
            } catch {
                print("Failed to load and parse JSON: \(error)")
            }
        }
    }
    
    func searchProduct(byName name: String) -> ProductDetails? {
        for category in categories {
            if let product = category.products?.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return product
            }
        }
        return nil
    }
}
