//
//  CartTableViewCell.swift
//  MyStore
//
//  Created by souvik_roy on 22/07/24.
//

import UIKit
protocol CartTableViewCellDelegate: AnyObject {
    func cartTableViewCellDidTapDelete(_ cell: CartTableViewCell)
    func cartTableViewCell(_ cell: CartTableViewCell, didChangeQuantityTo quantity: Int)
}

class CartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    
    weak var delegate: CartTableViewCellDelegate?
      
      func configure(with cartItem: CartItem) {
          productNameLabel.text = cartItem.name
          productPriceLabel.text = cartItem.price
          quantityLabel.text = "Quantity: \(cartItem.quantity)"
                  quantityStepper.value = Double(cartItem.quantity) // Set stepper to current quantity

                  if let imageURL = URL(string: cartItem.imageName) {
                      productImageView.kf.setImage(with: imageURL)
                  } else {
                      productImageView.image = UIImage(named: "placeholder_image")
                  }
              }

              @IBAction func deleteButtonTapped(_ sender: Any) {
                  delegate?.cartTableViewCellDidTapDelete(self)
              }

              @IBAction func quantityStepperChanged(_ sender: UIStepper) {
                  let newQuantity = Int(sender.value)
                  quantityLabel.text = "Quantity: \(newQuantity)"
                  delegate?.cartTableViewCell(self, didChangeQuantityTo: newQuantity)
              }
}

