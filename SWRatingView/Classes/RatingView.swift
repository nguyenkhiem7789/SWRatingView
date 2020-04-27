//
//  RatingView.swift
//  FBSnapshotTestCase
//
//  Created by Nguyen on 4/25/20.
//

import UIKit

@objc public protocol RatingViewDelegate {
    @objc optional func floatRatingView(_ ratingView: RatingView, didUpdate rating: Double)

    @objc optional func floatRatingView(_ ratingView: RatingView, isUpdating rating: Double)
}

@IBDesignable
open class RatingView: UIView {

    @objc public enum RatingViewType: Int {
        case wholeRatings

        case halfRatings

        func supportsFractions() -> Bool {
            return self == .halfRatings
        }
    }

    open weak var delegate: RatingViewDelegate?

    /// Array of empty image views
    private var emptyImageViews: [UIImageView] = []

    /// Array of select image views
    private var fullImageViews: [UIImageView] = []

    /// Set the empty image (e.x start outline)
    @IBInspectable open var emptyImage: UIImage? {
        didSet {
            for imageView in emptyImageViews {
                imageView.image = emptyImage
            }
            refresh()
        }
    }

    /// Set the full image that is overlayed on top of the empty image
    /// Should be same size and shape as the empty image
    @IBInspectable open var fullImage: UIImage? {
        didSet {
            for imageView in fullImageViews {
                imageView.image = fullImage
            }
            refresh()
        }
    }

    /// Set the empty and full image view content mode
    var imageContentMode: UIView.ContentMode = .scaleAspectFit

    /// minimum image size
    @IBInspectable var minImageSize = CGSize(width: 5.0, height: 5.0)

    /// Min rating value
    @IBInspectable var minRating: Int = 0 {
        didSet {
            if rating < Double(minRating) {
                rating = Double(minRating)
                refresh()
            }
        }
    }

    /// Max rating value
    @IBInspectable var maxRating: Int = 5 {
        didSet {
            if maxRating != oldValue {
                removeImageViews()
                initImageViews()
                setNeedsLayout()
                refresh()
            }
        }
    }

    @IBInspectable open var rating: Double = 0 {
        didSet {
            if rating != oldValue {
                refresh()
            }
        }
    }

    @IBInspectable open var type: RatingViewType = .wholeRatings

    @IBInspectable open var editable = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        initImageViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initImageViews()
    }

    private func initImageViews() {
        guard emptyImageViews.isEmpty && fullImageViews.isEmpty else {
            return
        }
        for _ in 0 ..< maxRating {
            let emptyImageView = UIImageView()
            emptyImageView.contentMode = imageContentMode
            emptyImageView.image = emptyImage
            emptyImageViews.append(emptyImageView)
            addSubview(emptyImageView)

            let fullImageView = UIImageView()
            fullImageView.contentMode = imageContentMode
            fullImageView.image = fullImage
            fullImageViews.append(fullImageView)
            addSubview(fullImageView)
        }
    }

    ///remove old image views
    private func removeImageViews() {
        for i in 0 ..< emptyImageViews.count {
            var imageView = emptyImageViews[i]
            imageView.removeFromSuperview()
            imageView = fullImageViews[i]
            imageView.removeFromSuperview()
        }
        emptyImageViews.removeAll(keepingCapacity: false)
        fullImageViews.removeAll(keepingCapacity: false)
    }

    /// set rating value
    public func setRating(rating: Double) {
        if type.supportsFractions() {
            self.rating = rating
        } else {
            print("round(rating)\(round(rating))")
            self.rating = round(rating)
        }
    }

    /// Refresh hides or shows full images
    private func refresh() {
        for i in 0 ..< fullImageViews.count {
            let imageView = fullImageViews[i]
            if rating >= Double(i + 1) {
                imageView.layer.mask = nil
                imageView.isHidden = false
            }
            else if rating > Double(i) && rating < Double(i + 1) {
                /// Set mask layer for full image
                let maskLayer = CALayer()
                maskLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(rating-Double(i)) * imageView.frame.size.width, height: imageView.frame.size.height)
                maskLayer.backgroundColor = UIColor.red.cgColor
                imageView.layer.mask = maskLayer
                imageView.isHidden = false
            } else {
                imageView.layer.mask = nil
                imageView.isHidden = true
            }
        }
    }

    /// Calculates the ideal ImageView size in a given CGSize
    private func sizeForImage(_ image: UIImage, inSize size: CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height
        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width
            return CGSize(width: width, height: size.height)
        } else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height
            return CGSize(width: size.width, height: height)
        }
    }

    /// Calculates new ratings based on touch location in view
    private func updateLocation(_ touch: UITouch) {
        guard editable else {
            return
        }
        let touchLocation = touch.location(in: self)
        var newRating: Double = 0
        for i in stride(from: (maxRating - 1), through: 0, by: -1) {
            let imageView = emptyImageViews[i]
            guard touchLocation.x > imageView.frame.origin.x else {
                continue
            }
            /// Find touch point in image view
            let newLocation = imageView.convert(touchLocation, from: self)
            /// Find decimal value for float or haft rating
            if imageView.point(inside: newLocation, with: nil) && (type.supportsFractions()) {
                let decimalNum = Double(newLocation.x / imageView.frame.size.width)
                newRating = Double(i) + decimalNum
                if type == .halfRatings {
                    newRating = Double(i) + (decimalNum > 0.75 ? 1 : (decimalNum > 0.25 ? 0.5 : 0))
                }
            } else {
                newRating = Double(i) + 1.0
            }
            break
        }
        /// check min rating
        rating = newRating < Double(minRating) ? Double(minRating) : newRating

        /// Update delegate
        delegate?.floatRatingView?(self, isUpdating: rating)
    }

    // MARK: UIView
    ///Override to calculate ImageView frames
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let emptyImage = emptyImage else { return }
        let desiredImageWidth = frame.size.width / CGFloat(emptyImageViews.count)
        let maxImageWidth = max(minImageSize.width, desiredImageWidth)
        let maxImageHeight = max(minImageSize.height, frame.size.height)
        let imageViewSize = sizeForImage(emptyImage, inSize: CGSize(width: maxImageWidth, height: maxImageHeight))
        let imageXOffset = (frame.size.width - (imageViewSize.width * CGFloat(emptyImageViews.count)))            / CGFloat((emptyImageViews.count - 1))
        for i in 0 ..< maxRating {
            let imageFrame = CGRect(x: i == 0 ? 0 : CGFloat(i) * (imageXOffset + imageViewSize.width), y: 0, width: imageViewSize.width, height: imageViewSize.height)
            var imageView = emptyImageViews[i]
            imageView.frame = imageFrame

            imageView = fullImageViews[i]
            imageView.frame = imageFrame
        }
        refresh()
    }

    // MARK: Touch events
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateLocation(touch)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateLocation(touch)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.floatRatingView?(self, didUpdate: rating)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.floatRatingView?(self, didUpdate: rating)
    }

}
