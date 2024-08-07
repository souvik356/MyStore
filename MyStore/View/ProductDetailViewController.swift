//
//  DetailViewController.swift
//  MyStore
//
//  Created by souvik_roy on 19/07/24.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productDescription: UITextView!
    
    @IBOutlet weak var productRating: UILabel!
    
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var cartIcon: UIImageView!
    
    @IBOutlet weak var quantityStepper: UIStepper!
    
    @IBOutlet weak var addToCartBtn: UIButton!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    
    var product: ProductDetails?
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           if let product = product {
               productName.text = product.name
               productDescription.text = product.description
               productRating.text = "\(product.rating) Star"
               productPrice.text = product.price
               
               // Load image using Kingfisher
               if let imageURL = URL(string: product.imageName) {
                   productImage.kf.setImage(with: imageURL)
               } else {
                   // Optionally, set a placeholder image or handle the error
                   productImage.image = UIImage(named: "placeholder_image")
               }
           }
           
           if let cartIcon = cartIcon {
               let tapAddGesture = UITapGestureRecognizer(target: self, action: #selector(cartIconTapped))
               cartIcon.isUserInteractionEnabled = true
               cartIcon.addGestureRecognizer(tapAddGesture)
           } else {
               print("cartIcon is nil")
           }
           
           // Configure stepper
           quantityStepper.minimumValue = 1
           quantityStepper.maximumValue = 99
           quantityStepper.value = 1
           quantityLabel.text = "\(Int(quantityStepper.value))"
           
           quantityStepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
           addToCartBtn.layer.cornerRadius = 10
           addToCartBtn.clipsToBounds = true
       }
       
       @objc func stepperValueChanged(_ sender: UIStepper) {
           quantityLabel.text = "\(Int(sender.value))"
       }
       
       @objc func cartIconTapped() {
           let storyBoard = UIStoryboard(name: "Main", bundle: nil)
           let cartVc = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
           navigationController?.pushViewController(cartVc, animated: true)
       }
       
       @IBAction func buyBtn(_ sender: Any) {
           guard let product = product else { return }
           
           let quantity = Int(quantityStepper.value)
           
           let cartItem = CartItem(
               id: product.id,
               name: product.name,
               price: product.price,
               imageName: product.imageName,
               quantity: quantity
           )
           
           CartManager.shared.addToCart(cartItem)
           print("Items added successfully")
           
           // Optionally, show a confirmation or alert
           let alert = UIAlertController(title: "Added to Cart", message: "\(product.name) has been added to your cart.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
        
    }
    
    
    

