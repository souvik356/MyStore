//
//  CartManager.swift
//  MyStore
//
//  Created by souvik_roy on 19/07/24.
//

import Foundation


class CartManager {
    static let shared = CartManager()
    
    private let cartItemsKey = "cartItemsKey"
    private let orderedItemsKey = "orderedItemsKey"
    private var cartItems: [CartItem] = []
    private var orderedItems: [CartItem] = []
    
    private init() {
        loadCartItems()
        loadOrderedItems()
    }
    
    func addToCart(_ item: CartItem) {
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                cartItems[index].quantity += item.quantity
            } else {
                cartItems.append(item)
            }
            saveCartItems()
        }
    
    func getCartItems() -> [CartItem] {
        return cartItems
    }
    
    func removeFromCart(at index: Int) {
        guard index >= 0 && index < cartItems.count else { return }
        cartItems.remove(at: index)
        saveCartItems()
        print("Item removed successfully")
        print("Updated total price: \(getTotalPrice())")
    }
    
    func getTotalPrice() -> Double {
        return cartItems.reduce(0) { total, item in
            guard let itemPrice = convertPriceStringToDouble(item.price) else { return total }
            return total + (itemPrice * Double(item.quantity))
        }
    }
    
    private func convertPriceStringToDouble(_ priceString: String) -> Double? {
        let cleanedString = priceString
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleanedString)
    }
    
    private func saveCartItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(cartItems) {
            UserDefaults.standard.set(data, forKey: cartItemsKey)
        }
    }
    
    private func loadCartItems() {
        if let data = UserDefaults.standard.data(forKey: cartItemsKey) {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([CartItem].self, from: data) {
                cartItems = items
            }
        }
    }
    func updateQuantity(at index: Int, to quantity: Int) {
           guard index >= 0 && index < cartItems.count else { return }
           cartItems[index].quantity = quantity
           saveCartItems()
       }
    func placeOrder() {
        orderedItems.append(contentsOf: cartItems)
        saveOrderedItems()
        clearCart()
    }
    
    func getOrderedItems() -> [CartItem] {
        return orderedItems
    }
    
    private func saveOrderedItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(orderedItems) {
            UserDefaults.standard.set(data, forKey: orderedItemsKey)
        }
    }
    
    private func loadOrderedItems() {
        if let data = UserDefaults.standard.data(forKey: orderedItemsKey) {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([CartItem].self, from: data) {
                orderedItems = items
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        saveCartItems()
    }
    
    // this help us to perform deletion in Ordered Item Section
    
   // Assuming this is inside CartManager or wherever you manage the cart
//    func removeOrderedItem(at index: Int) {
//        // Ensure orderedItems has at least one item at the given index
//        guard index < orderedItems.count else { return }
//
//        // Get the orderId from the orderedItems
//        let orderId = orderedItems[index].id
//
//        // Reference to Firebase
//        let ordersRef = Database.database().reference().child("orders").child(orderId)
//
//        // Remove from Firebase
//        ordersRef.removeValue { error, _ in
//            if let error = error {
//                print("Error deleting order: \(error)")
//            } else {
//                // Successfully removed from Firebase, now remove from local list
//                self.orderedItems.remove(at: index)
//                // Notify any observers or update UI as necessary
//            }
//        }
//    }
}
