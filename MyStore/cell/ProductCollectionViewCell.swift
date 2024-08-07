//
//  ProductCollectionViewCell.swift
//  MyStore
//
//  Created by souvik_roy on 17/07/24.
//

import UIKit
import Kingfisher

class ProductCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var productImageLabel: UIImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    
    
    func configure(prod: ProductDetails) {
           print("configure function")
           if let url = toUrl(str: prod.imageName) {
               print("Image URL: \(url)")
               self.productImageLabel.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
           } else {
               print("Invalid URL: \(prod.imageName)")
               self.productImageLabel.image = UIImage(named: "placeholder")
           }
           self.productNameLabel.text = prod.name
       }
       
       func toUrl(str: String) -> URL? {
           return URL(string: str.trimmingCharacters(in: .whitespacesAndNewlines))
       }
    
}
