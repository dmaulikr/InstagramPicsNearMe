//
//  CustomLayout.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/19/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit

protocol CustomLayoutDelegate {
    
  func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    
}

class CustomLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var photoHeight: CGFloat = 0
  
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! CustomLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  override func isEqual(object: AnyObject?) -> Bool {
    if let attributes = object as? CustomLayoutAttributes {
      if attributes.photoHeight == photoHeight {
        return super.isEqual(object)
      }
    }
    return false
  }
  
}

class CustomLayout: UICollectionViewLayout {

    var cellPadding: CGFloat = 0
    var delegate: CustomLayoutDelegate!
    var numberOfColumns = 1

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        get {
            let insets = collectionView!.contentInset
            return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
//            return CGRectGetWidth(collectionView!.bounds)
        }
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return CustomLayoutAttributes.self
    }
  
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepareLayout() {
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
      
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * columnWidth)
            }
      
            var yOffsets = [CGFloat](count: numberOfColumns, repeatedValue: 0)
      
            var column = 0
            for item in 0..<collectionView!.numberOfItemsInSection(0) {
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                let width = columnWidth - (cellPadding * 2)
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding + photoHeight + annotationHeight + cellPadding
        
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                let attributes = CustomLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = insetFrame
                attributes.photoHeight = photoHeight
                cache.append(attributes)
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffsets[column] = yOffsets[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        }
    }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    for attributes in cache {
      if CGRectIntersectsRect(attributes.frame, rect) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
  
}
