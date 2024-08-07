//
//  ProductListViewController.swift
//  MyStore
//
//  Created by souvik_roy on 10/07/24.ShoesS

import UIKit
import Firebase
import FirebaseDatabase

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CategoryTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var searchField: UITextField!
    
    
    var productData: ProductModel?
       var filteredProducts: [ProductDetails] = []
       var ref: DatabaseReference!
       
       private let refreshControl = UIRefreshControl()
       private var activityIndicator: UIActivityIndicatorView!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.delegate = self
           tableView.dataSource = self
           ref = Database.database().reference()
           self.title = "Shoppie"
           
           // Configure and add refresh control
           refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
           tableView.refreshControl = refreshControl
           
           // Setup activity indicator
           activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.center = self.view.center
           self.view.addSubview(activityIndicator)
           
           fetchProductsFromFirebase()
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           fetchProductsFromFirebase()
           tableView.reloadData() // Ensure data is reloaded when the view appears
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           fetchProductsFromFirebase()
           tableView.reloadData() // Ensure data is reloaded when the view appears
       }
       
       @IBAction func searchFunction(_ sender: Any) {
           print("Search button Tapped")
           guard let searchText = searchField.text, !searchText.isEmpty else {
               // Optionally, you can show an alert or handle empty search text here
               return
           }
           
           // Filter products based on the search text
           var matchingProducts: [ProductDetails] = []
           
           for category in productData?.response ?? [] {
               if let products = category.products {
                   let filtered = products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                   matchingProducts.append(contentsOf: filtered)
               }
           }
           
           if matchingProducts.isEmpty {
               let alert = UIAlertController(title: "No Results", message: "No product found with the name \(searchText).", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           } else {
               // Navigate to ProductDetailViewController with the first matching product
               if let firstProduct = matchingProducts.first {
                   let storyboard = UIStoryboard(name: "Main", bundle: nil)
                   if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
                       detailVC.product = firstProduct
                       self.navigationController?.pushViewController(detailVC, animated: true)
                   }
               }
           }
       }
       
       @objc private func refreshData() {
           fetchProductsFromFirebase()
       }
       
       func fetchProductsFromFirebase() {
           // Show activity indicator
           activityIndicator.startAnimating()
           
           ref.child("products").child("response").observeSingleEvent(of: .value) { snapshot in
           print("productsss:- \(snapshot)")
               if snapshot.exists() {
                   if let snapshotArray = snapshot.value as? [[String: Any]] {
                       var products: [Product] = []
                       
                       for categoryDict in snapshotArray {
                           if let categoryName = categoryDict["category_name"] as? String,
                              let productsData = categoryDict["products"] as? [[String: Any]] {
                               
                               var productDetailsArray: [ProductDetails] = []
                               for productData in productsData {
                                   if let id = productData["id"] as? Int,
                                      let name = productData["name"] as? String,
                                      let imageName = productData["image_name"] as? String,
                                      let price = productData["price"] as? String,
                                      let description = productData["description"] as? String,
                                      let rating = productData["rating"] as? String {
                                       
                                       let productDetails = ProductDetails(id: id, name: name, imageName: imageName, price: price, description: description, rating: rating)
                                       productDetailsArray.append(productDetails)
                                   }
                               }
                               
                               let product = Product(categoryName: categoryName, products: productDetailsArray)
                               products.append(product)
                           }
                       }
                       
                       self.productData = ProductModel(response: products)
                       print("souvik product data \(self.productData)")
                       self.tableView.reloadData() // Refresh table view
                   } else {
                       print("Error: Snapshot value is not an array")
                   }
               } else {
                   print("Snapshot does not exist")
               }
               
               // Hide activity indicator
               self.activityIndicator.stopAnimating()
               self.refreshControl.endRefreshing() // End refreshing animation
           } withCancel: { error in
               print("Error fetching data: \(error.localizedDescription)")
               
               // Hide activity indicator
               self.activityIndicator.stopAnimating()
               self.refreshControl.endRefreshing() // End refreshing animation
           }
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return productData?.response?.count ?? 0
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? CategoryTableViewCell else {
               return UITableViewCell()
           }
           if let category = productData?.response?[indexPath.row] {
               print("Souvik Category:- \(category)")
               cell.categoryName.text = category.categoryName
               print("category Name :- \(cell.categoryName)")
               cell.products = category.products ?? [] // Set products for the cell
               print("product's array :- \(cell.products) ")
               cell.collectionView.reloadData() // Refresh collection view
               cell.delegate = self // Set the delegate
           }
           return cell
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 220.0
       }
       
       func didSelectProduct(_ product: ProductDetails) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
               detailVC.product = product
               self.navigationController?.pushViewController(detailVC, animated: true)
           }
       }
}


    


