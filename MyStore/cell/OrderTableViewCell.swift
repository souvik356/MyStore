//
//  OrderTableViewCell.swift
//  MyStore
//
//  Created by souvik_roy on 23/07/24.
//

import UIKit

protocol OrderTableViewCellDelegate: AnyObject {
    func orderTableViewCellDidTapDelete(_ cell: OrderTableViewCell)
}

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var prductImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    
}
