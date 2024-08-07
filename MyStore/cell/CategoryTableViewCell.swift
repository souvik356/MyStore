//
//  CategoryTableViewCell.swift
//  MyStore
//
//  Created by souvik_roy on 17/07/24.
//

import UIKit
import Kingfisher

protocol CategoryTableViewCellDelegate: AnyObject {
    func didSelectProduct(_ product: ProductDetails)
}

class CategoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    var products: [ProductDetails] = [] {
           didSet {
               DispatchQueue.main.async {
                   self.collectionView.reloadData()
               }
           }
       }
       
       weak var delegate: CategoryTableViewCellDelegate?
       
       override func awakeFromNib() {
           super.awakeFromNib()
           collectionView.delegate = self
           collectionView.dataSource = self
           collectionView.reloadData()
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return products.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
           
           let product = products[indexPath.row]
           
           // Debug print statements to check URLs
           print("Product image name: \(product.imageName)")
           
           cell.configure(prod: product)
           
           return cell
       }

       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let selectedProduct = products[indexPath.row]
           delegate?.didSelectProduct(selectedProduct)
       }
}

