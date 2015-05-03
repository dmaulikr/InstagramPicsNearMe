//
//  RoundedCornersView.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/19/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornersView: UIView {
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
      layer.masksToBounds = cornerRadius > 0
    }
  }
  
}