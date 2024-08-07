//
//  ProductViewModal.swift
//  MyStore
//
//  Created by souvik_roy on 10/07/24.
//

import Foundation

class ProductViewModel {
    
    var productData: ProductModel?
    
    func fetchProducts() {
        if let path = Bundle.main.path(forResource: "EcommerceJson", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                productData = try decoder.decode(ProductModel.self, from: data)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
    
    var categoryCount: Int {
        return productData?.response?.count ?? 0
    }
    
    func products(forCategoryIndex index: Int) -> [ProductDetails]? {
            guard let categories = productData?.response else { return nil }
            guard index >= 0 && index < categories.count else { return nil }
            return categories[index].products
        }
}


		
