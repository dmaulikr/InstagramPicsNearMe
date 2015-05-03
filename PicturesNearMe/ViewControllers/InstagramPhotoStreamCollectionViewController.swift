//
//  InstagramMediaSearchViewController.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/19/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class InstagramPhotoStreamCollectionViewController : UICollectionViewController {

    var coordinates : CLLocationCoordinate2D!
    var tappedCoordinates : CLLocationCoordinate2D!
    var distance : Double!
    private var instagramMedia : NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            fetchInstagramPhoto();
        }
        
        if let patternImage = UIImage(named: "Pattern") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
    
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        let layout = collectionViewLayout as! CustomLayout
        layout.cellPadding = 5
        layout.delegate = self
        layout.numberOfColumns = 2
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func fetchInstagramPhoto() {
        InstagramApiRepository.sharedInstance.getMedia(coordinates!, distance: distance!, completionHandler: { (instaMediaArray) -> Void in
                self.instagramMedia = instaMediaArray
                for instaMediaObj in self.instagramMedia {
                    let instaMedia = instaMediaObj as! InstaMedia
                    let locationInstaMediaCoordinates = CLLocation(latitude: instaMedia.locationCoordinate.latitude, longitude: instaMedia.locationCoordinate.longitude)
                    let locationTappedCoordinates = CLLocation(latitude: self.tappedCoordinates.latitude, longitude: self.tappedCoordinates.longitude)
                    instaMedia.distance = locationInstaMediaCoordinates.distanceFromLocation(locationTappedCoordinates)
                }
                self.collectionView!.reloadData()
            })
    }
}

extension InstagramPhotoStreamCollectionViewController {
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return instagramMedia.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnnotatedPhotoCell", forIndexPath: indexPath) as! AnnotatedPhotoCell
    cell.instagramPhoto = instagramMedia[indexPath.item] as? InstaMedia
    let imageUrlString = NSURL(string: cell.instagramPhoto!.imageUrl)
    // The image isn't cached, download the img data
    // We should perform this in a background thread
    let request = NSURLRequest(URL: imageUrlString!)
    let mainQueue = NSOperationQueue.mainQueue()
    NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
        if error == nil {
            // Convert the downloaded data in to a UIImage object
            let image = UIImage(data: data)
            // Update the cell
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = self.collectionView!.cellForItemAtIndexPath(indexPath) {
                        cell.instagramImage = image
                        }
                })
            }
        else {
            println("Error: \(error.localizedDescription)")
        }
    })
    return cell
  }
  
}

extension InstagramPhotoStreamCollectionViewController: CustomLayoutDelegate {
  
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let instaMedia = instagramMedia[indexPath.item] as? InstaMedia
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(instaMedia!.image.size, boundingRect)
        return rect.height
    }
  
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        return 60
    }
  
}
