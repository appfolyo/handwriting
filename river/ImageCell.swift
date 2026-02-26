//
//  ImageCell.swift
//  river
//
//  Created by Dev on 2026.02.23.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var contentImageView: AutoInvertImageView!
    
    @IBOutlet weak var linkSymbol: UIImageView!
    
    @IBOutlet weak var newLabel: RoundedPaddingLabel!
    @IBOutlet weak var newLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
}
