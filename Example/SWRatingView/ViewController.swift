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

    @IBOutlet weak var ratingView: RatingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ratingView.backgroundColor = UIColor.clear
        ratingView.contentMode = UIView.ContentMode.scaleAspectFit
//        ratingView.delegate = self
    }

}

extension ViewController: RatingViewDelegate {
    func floatRatingView(_ ratingView: RatingView, isUpdating rating: Double) {

    }

    func floatRatingView(_ ratingView: RatingView, didUpdate rating: Double) {
    }
}

