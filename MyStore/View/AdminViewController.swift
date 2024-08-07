//
//  AdminViewController.swift
//  MyStore
//
//  Created by souvik_roy on 29/07/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AdminViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, ProductCellDelegate {

       @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeLabel: UILabel!

    @IBOutlet weak var addBtn: UIButton!
    
    var productDetails: [ProductDetails] = []

       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.delegate = self
           tableView.dataSource = self
           loadProducts()

           // Set up close label
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeLabelTapped))
           closeLabel.isUserInteractionEnabled = true
           closeLabel.addGestureRecognizer(tapGesture)
           addBtn.layer.cornerRadius = 10
           addBtn.clipsToBounds = true
       }

       @objc func closeLabelTapped() {
           dismiss(animated: true, completion: nil)
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    
    }
    
    
    @IBAction func AddProductBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVc = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        addVc.modalPresentationStyle = .fullScreen
        present(addVc, animated: true)
    }
    
       func loadProducts() {
           let ref = Database.database().reference().child("products")
           ref.observe(.value) { snapshot in
               var loadedProducts: [ProductDetails] = []

               guard let productsDict = snapshot.value as? [String: Any],
                     let responseArray = productsDict["response"] as? [[String: Any]] else {
                   print("Error parsing data")
                   return
               }

               for categoryDict in responseArray {
                   if let productsArray = categoryDict["products"] as? [[String: Any]] {
                       for productDict in productsArray {
                           if let id = productDict["id"] as? Int,
                              let name = productDict["name"] as? String,
                              let imageName = productDict["image_name"] as? String,
                              let price = productDict["price"] as? String,
                              let description = productDict["description"] as? String,
                              let rating = productDict["rating"] as? String {
                               let product = ProductDetails(id: id, name: name, imageName: imageName, price: price, description: description, rating: rating)
                               loadedProducts.append(product)
                           }
                       }
                   }
               }

               self.productDetails = loadedProducts
               self.tableView.reloadData()
           } withCancel: { error in
               print("Error fetching data: \(error.localizedDescription)")
           }
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return productDetails.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
           let product = productDetails[indexPath.row]
           cell.productNameLabel.text = product.name
           cell.productPriceLabel.text = product.price
           cell.delegate = self
           return cell
       }

       func didTapEditButton(in cell: ProductTableViewCell) {
           if let indexPath = tableView.indexPath(for: cell) {
                      let product = productDetails[indexPath.row]
                      let storyboard = UIStoryboard(name: "Main", bundle: nil)
                      let editVC = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
                      editVC.product = product
                      editVC.modalPresentationStyle = .fullScreen
                      present(editVC, animated: true, completion: nil)
                  }
       }

    func didTapDeleteButton(in cell: ProductTableViewCell) {
           if let indexPath = tableView.indexPath(for: cell) {
               let product = productDetails[indexPath.row]
               // Handle deleting logic here
               deleteProduct(product: product)
           }
       }

       func deleteProduct(product: ProductDetails) {
           let ref = Database.database().reference().child("products/response")
           ref.observeSingleEvent(of: .value) { snapshot in
               guard var responseArray = snapshot.value as? [[String: Any]] else {
                   print("Error parsing data")
                   return
               }
               
               //Remove images from Firebase Storage
               let storageRef = Storage.storage().reference().child("\(product.name)"+".png")
               
               storageRef.delete { error in
                   if let error = error{
                       print(error.localizedDescription)
                   }
               }

               // Variable to hold the index of the category containing the product to delete
               var categoryIndex: Int?
               var productIndex: Int?

               // Loop through the categories to find the product
               for (index, categoryDict) in responseArray.enumerated() {
                   if var productsArray = categoryDict["products"] as? [[String: Any]] {
                       for (pIndex, productDict) in productsArray.enumerated() {
                           if let id = productDict["id"] as? Int, id == product.id {
                               categoryIndex = index
                               productIndex = pIndex
                               break
                           }
                       }
                       if categoryIndex != nil && productIndex != nil {
                           break
                       }
                   }
               }

               // If the category and product index are found, proceed to delete the product
               if let categoryIndex = categoryIndex, let productIndex = productIndex {
                   var categoryDict = responseArray[categoryIndex]
                   var productsArray = categoryDict["products"] as? [[String: Any]] ?? []
                   productsArray.remove(at: productIndex)
                   categoryDict["products"] = productsArray
                   responseArray[categoryIndex] = categoryDict

                   // Update the database
                   ref.setValue(responseArray) { error, _ in
                       if let error = error {
                           print("Error deleting product: \(error.localizedDescription)")
                       } else {
                           print("Product deleted successfully!")
                           self.loadProducts() // Reload the products to update the UI
                       }
                   }
               } else {
                   print("Product not found")
               }
           }
       }}
