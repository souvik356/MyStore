//
//  ProfileViewController.swift
//  MyStore
//
//  Created by souvik_roy on 23/07/24.
//

import UIKit
import FirebaseAuth
import Firebase
import Kingfisher
import FirebaseDatabase

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var modalLbl: UILabel!
    private var orderedItems: [(id: String, item: CartItem)] = []
    @IBOutlet weak var manageProductButton: UIButton! // Added IBOutlet
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    //       private var orderedItems: [(id: String, item: CartItem)] = []

       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.delegate = self
           tableView.dataSource = self
           updateOrderedItems()
           empty()
           checkAdmin() // Check if the logged-in user is an admin
           fetchUserName()
           logOutBtn.layer.cornerRadius = 10
           logOutBtn.clipsToBounds = true
           manageProductButton.layer.cornerRadius = 10
           logOutBtn.clipsToBounds = true
       }

       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           updateOrderedItems()
           empty()
       }

       @IBAction func logoutButton(_ sender: Any) {
           let firebaseAuth = Auth.auth()
           do {
               try firebaseAuth.signOut()
               let vc = storyboard?.instantiateViewController(withIdentifier: "AuthRegisterViewController") as! AuthRegisterViewController
               let controller = UINavigationController(rootViewController: vc)
               controller.modalPresentationStyle = .fullScreen
               controller.modalTransitionStyle = .coverVertical
               self.present(controller, animated: true)
           } catch let signOutError as NSError {
               print("Error signing out: %@", signOutError)
           }
       }

       @IBAction func manageProductsBtnPressed(_ sender: Any) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let adminVc = storyboard.instantiateViewController(withIdentifier: "AdminViewController") as! AdminViewController
           adminVc.modalPresentationStyle = .fullScreen
           present(adminVc, animated: true)
       }

       private func updateOrderedItems() {
           guard let userId = Auth.auth().currentUser?.uid else { return }
           let ordersRef = Database.database().reference().child("orders").queryOrdered(byChild: "userId").queryEqual(toValue: userId)

           ordersRef.observeSingleEvent(of: .value) { snapshot in
               var newOrderedItems: [(id: String, item: CartItem)] = []
               for child in snapshot.children {
                   if let snapshot = child as? DataSnapshot,
                      let dict = snapshot.value as? [String: Any],
                      let orderId = snapshot.key as? String,  // Ensure orderId is a String
                      let items = dict["items"] as? [[String: Any]] {
                       for item in items {
                           if let id = item["productId"] as? Int,
                              let name = item["productName"] as? String,
                              let price = item["price"] as? String,
                              let imageName = item["imageName"] as? String,
                              let quantity = item["quantity"] as? Int {
                               newOrderedItems.append((id: orderId, item: CartItem(id: id, name: name, price: price, imageName: imageName, quantity: quantity)))
                           }
                       }
                   }
               }
               self.orderedItems = newOrderedItems
               self.tableView.reloadData()
               self.empty()
           }
       }

       private func empty() {
           if orderedItems.isEmpty {
               tableView.isHidden = true
               modalLbl.isHidden = false
           } else {
               tableView.isHidden = false
               modalLbl.isHidden = true
           }
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return orderedItems.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
           let orderedItem = orderedItems[indexPath.row].item
           cell.productNameLabel.text = orderedItem.name
           if let imageURL = URL(string: orderedItem.imageName) {
               cell.prductImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder_image"))
           } else {
               cell.prductImageView.image = UIImage(named: "placeholder_image")
           }
           return cell
       }

       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 200
       }

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // Check if indexPath.row is valid
               guard indexPath.row >= 0 && indexPath.row < orderedItems.count else {
                   print("Error: IndexPath.row out of range: \(indexPath.row)")
                   return
               }

               let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item from your ordered items? This action cannot be undone.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                   self.removeOrderedItem(at: indexPath.row)
               }))
               present(alert, animated: true, completion: nil)
           }
       }

       private func deleteOrder(at indexPath: IndexPath) {
           let orderId = orderedItems[indexPath.row].id  // Ensure this is a String
           let ordersRef = Database.database().reference().child("orders").child(orderId)

           ordersRef.removeValue { error, _ in
               if let error = error {
                   print("Error deleting order: \(error)")
               } else {
                   self.removeOrderedItem(at: indexPath.row)
                   self.updateOrderedItems()
                   self.empty()
                   self.showDeletionFeedback()
               }
           }
       }

       private func showDeletionFeedback() {
           let feedbackAlert = UIAlertController(title: "Item Deleted", message: "Your Order is cancelled", preferredStyle: .alert)
           feedbackAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(feedbackAlert, animated: true, completion: nil)
       }

       func removeOrderedItem(at index: Int) {
           // Check if the index is valid
           guard index >= 0 && index < orderedItems.count else {
               print("Index out of range: \(index)")
               return
           }

           // Get the orderId from the orderedItems
           let orderId = orderedItems[index].id

           // Reference to Firebase
           let ordersRef = Database.database().reference().child("orders").child(orderId)

           // Remove from Firebase
           ordersRef.removeValue { error, _ in
               if let error = error {
                   print("Error deleting order: \(error)")
               } else {
                   // Successfully removed from Firebase, now remove from local list
                   DispatchQueue.main.async {
                       self.orderedItems.remove(at: index)
                       self.tableView.reloadData() // Ensure the table view updates
                       self.empty()
                   }
               }
           }
       }

       private func checkAdmin() {
           if let currentUser = Auth.auth().currentUser {
               let adminEmail = "admin@gmail.com"
               if currentUser.email == adminEmail {
                   // Hide the "Manage Product" button for the admin
                   manageProductButton.isHidden = false
               } else {
                   // Show the "Manage Product" button for other users
                   manageProductButton.isHidden = true
               }
           }
       }
    
    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User ID not found")
            return
        }

        let userRef = Database.database().reference().child("RegisterUser").child(userId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let userDict = snapshot.value as? [String: Any],
               let userName = userDict["name"] as? String {
                self.userNameLbl.text = "Hi, \(userName.capitalized)"
            } else {
                self.userNameLbl.text = "User"
                print("Error: User name not found in the database for userId \(userId)")
            }
        } withCancel: { error in
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
}
