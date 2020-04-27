//
//  ViewController.swift
//  SWRatingView
//
//  Created by nguyenkhiem7789@gmail.com on 04/25/2020.
//  Copyright (c) 2020 nguyenkhiem7789@gmail.com. All rights reserved.
//

import UIKit
import SWRatingView

class ViewController: UIViewController {

    @IBOutlet weak var typeControlView: UISegmentedControl!

    @IBOutlet weak var ratingView: RatingView!

    @IBOutlet weak var ratingValueTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ratingView.backgroundColor = UIColor.clear
        ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        ratingView.delegate = self

        typeControlView.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
    }

    @objc func indexChanged(_ sender: UISegmentedControl) {
        if typeControlView.selectedSegmentIndex == 0 {
            self.ratingView.type = .wholeRatings
        } else if typeControlView.selectedSegmentIndex == 1 {
            self.ratingView.type = .halfRatings
        }
    }

    @IBAction func clickUpdateButton(_ sender: Any) {
        if let newRating = ratingValueTextField.text, let value = Double(newRating) {
            ratingView.setRating(rating: value)
            ratingValueTextField.text = nil
        }
    }

}

extension ViewController: RatingViewDelegate {
    func floatRatingView(_ ratingView: RatingView, isUpdating rating: Double) {

    }

    func floatRatingView(_ ratingView: RatingView, didUpdate rating: Double) {
    }
}

