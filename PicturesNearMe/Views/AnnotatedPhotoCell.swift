//
//  AnnotatedPhotoCell.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/19/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit

class AnnotatedPhotoCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
  @IBOutlet private weak var username: UILabel!
  @IBOutlet private weak var distance: UILabel!
  
  private let formatterTwoDecimalDigits = ".2"
  
  var instagramImage : UIImage? {
    didSet {
        if let instagramImage = instagramImage {
            self.imageView.image = instagramImage
        }
    }
  }
  
  var instagramPhoto: InstaMedia? {
    didSet {
      if let instagramPhoto = instagramPhoto {
        imageView.image = instagramPhoto.image
        username.text = instagramPhoto.username
        distance.text = String("\((instagramPhoto.distance/1000).format(formatterTwoDecimalDigits)) km")
      }
    }
  }
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    super.applyLayoutAttributes(layoutAttributes)
    let attributes = layoutAttributes as! CustomLayoutAttributes
    imageViewHeightLayoutConstraint.constant = attributes.photoHeight
  }
}
