//
//  RoundedPaddingLabel.swift.swift
//  river
//
//  Created by Dev on 2026.02.22.
//

import UIKit

@IBDesignable
class RoundedPaddingLabel: UILabel {

    // MARK: - Padding (IBInspectable)

    @IBInspectable var paddingTop: CGFloat = 6 {
        didSet { invalidateIntrinsicContentSize() }
    }

    @IBInspectable var paddingBottom: CGFloat = 6 {
        didSet { invalidateIntrinsicContentSize() }
    }

    @IBInspectable var paddingLeft: CGFloat = 10 {
        didSet { invalidateIntrinsicContentSize() }
    }

    @IBInspectable var paddingRight: CGFloat = 10 {
        didSet { invalidateIntrinsicContentSize() }
    }

    // MARK: - Corner radius

    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    // MARK: - Text drawing with padding

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: paddingTop,
            left: paddingLeft,
            bottom: paddingBottom,
            right: paddingRight
        )
        super.drawText(in: rect.inset(by: insets))
    }

    // MARK: - Intrinsic size (important!)

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + paddingLeft + paddingRight,
            height: size.height + paddingTop + paddingBottom
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = bounds.width
    }

    // Interface Builder preview
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
