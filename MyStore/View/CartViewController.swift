//
//  CartViewController.swift
//  MyStore
//
//  Created by souvik_roy on 19/07/24.
//

import UIKit
import Firebase
import FirebaseDatabase

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CartTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyCartLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var placeYrOrderBtn: UIButton!
    
//    @IBOutlet weak var deleteBtn: UIButton!
    private var cartItems: [CartItem] = []
        private var databaseRef: DatabaseReference!

        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.delegate = self
            tableView.dataSource = self
            self.title = "Cart"
            updateCartItems()
            databaseRef = Database.database().reference()
            placeYrOrderBtn.layer.cornerRadius = 10
            placeYrOrderBtn.clipsToBounds = true
        }

        @IBAction func orderBtnPressed(_ sender: Any) {
            addOrderToFirebase()
            CartManager.shared.placeOrder()
            updateCartItems()
            showAlert()
        }

        private func addOrderToFirebase() {
            let userId = Auth.auth().currentUser?.uid ?? "default_user"
            let orderId = databaseRef.child("orders").childByAutoId().key ?? UUID().uuidString
            let timestamp = Int(Date().timeIntervalSince1970)

            var orderItems: [[String: Any]] = []
            for item in cartItems {
                orderItems.append([
                    "productId": item.id,
                    "productName": item.name,
                    "price": item.price,
                    "quantity": item.quantity,
                    "imageName": item.imageName
                ])
            }

            let orderData: [String: Any] = [
                "userId": userId,
                "orderId": orderId,
                "items": orderItems,
                "totalPrice": CartManager.shared.getTotalPrice(),
                "timestamp": timestamp
            ]

            databaseRef.child("orders").child(orderId).setValue(orderData) { error, _ in
                if let error = error {
                    print("Error adding order to Firebase: \(error.localizedDescription)")
                } else {
                    print("Order successfully added to Firebase")
                }
            }
        }

        private func showAlert() {
            let alert = UIAlertController(title: "Order Placed", message: "Your order has been placed successfully.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateCartItems()
        }

        private func updateCartItems() {
            cartItems = CartManager.shared.getCartItems()
            tableView.reloadData()
            updateEmptyCartLabel()
            updateTotalPrice()
        }

        private func updateEmptyCartLabel() {
            emptyCartLabel.isHidden = !cartItems.isEmpty
            emptyCartLabel.text = cartItems.isEmpty ? "Hey, add items to your bag!" : ""
        }

        private func updateTotalPrice() {
            let totalPrice = CartManager.shared.getTotalPrice()
            totalPriceLabel.text = String(format: "Total Price: ₹%.2f", totalPrice)
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cartItems.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell

            let cartItem = cartItems[indexPath.row]
            cell.configure(with: cartItem)
            cell.delegate = self

            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 355 // Adjusted for stepper inclusion
        }

        func cartTableViewCellDidTapDelete(_ cell: CartTableViewCell) {
            guard let indexPath = tableView.indexPath(for: cell) else { return }

            let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item from your cart?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                CartManager.shared.removeFromCart(at: indexPath.row)
                self.updateCartItems()
            }))

            present(alert, animated: true)
        }

        func cartTableViewCell(_ cell: CartTableViewCell, didChangeQuantityTo quantity: Int) {
            guard let indexPath = tableView.indexPath(for: cell) else { return }

            CartManager.shared.updateQuantity(at: indexPath.row, to: quantity)
            updateCartItems()
        }
}
