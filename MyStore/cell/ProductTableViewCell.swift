//
//  ProductTableViewCell.swift
//  MyStore
//
//  Created by souvik_roy on 29/07/24.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
        @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        editBtn.layer.cornerRadius = 10
        editBtn.clipsToBounds = true
        
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.clipsToBounds = true
    }

    
        // Add delegate to handle button actions
        weak var delegate: ProductCellDelegate?

        @IBAction func editButtonTapped(_ sender: UIButton) {
            delegate?.didTapEditButton(in: self)
        }

        @IBAction func deleteButtonTapped(_ sender: UIButton) {
            delegate?.didTapDeleteButton(in: self)
        }
    }

    protocol ProductCellDelegate: AnyObject {
        func didTapEditButton(in cell: ProductTableViewCell)
        func didTapDeleteButton(in cell: ProductTableViewCell)

}
