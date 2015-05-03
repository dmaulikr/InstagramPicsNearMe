//
//  ViewController.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/18/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var radiusLabel: UILabel!
    
    private var locationManager: CLLocationManager!
    private var isDraggigSlider: Bool!
    private var tappedCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isDraggigSlider = false
        self.mapView.delegate = self
        self.mapView.scrollEnabled = false
        self.mapView.zoomEnabled = false
        
        // Initialize LocationManager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthorizationStatus()
    }

    @IBAction func sliderValueChanged(sender: AnyObject) {
        if isDraggigSlider == true {
            if self.locationManager.location != nil {
                centerMapOnLocation(self.locationManager.location, distance: self.distanceSlider.value)
            }
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7 (although we don't support iOS 7, it's a good practice).
            if self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    @IBAction func mapViewTapped(sender: UITapGestureRecognizer) {
        let touchPoint = sender.locationInView(self.mapView)
        let location = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        self.tappedCoordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mediaSearchController = storyboard.instantiateViewControllerWithIdentifier("InstagramPhotoStreamCollectionViewController") as! InstagramPhotoStreamCollectionViewController
        mediaSearchController.tappedCoordinates = self.tappedCoordinates
        if self.locationManager.location != nil {
            mediaSearchController.coordinates = self.locationManager.location.coordinate
        }
        mediaSearchController.distance = Double(self.distanceSlider.value)
        self.showViewController(mediaSearchController, sender: self)
    }
    
    @IBAction func sliderTouchUpInside(sender: AnyObject) {
        isDraggigSlider = false;
    }
    
    @IBAction func sliderTouchDown(sender: AnyObject) {
        isDraggigSlider = true;
    }
    
    func centerMapOnLocation(location: CLLocation, distance: Float) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, Double(distance), Double(distance))
        mapView.setRegion(coordinateRegion, animated: false)
    }

}

extension MapViewController : MKMapViewDelegate {

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let distanceRadius = Float(mapView.getRadius())
        if !isDraggigSlider {
            self.distanceSlider.value = distanceRadius
        }
        let formatterTwoDecimalDigits = ".2"
        let value = (Double(self.distanceSlider.value)/1000).format(formatterTwoDecimalDigits)
        self.radiusLabel.text = String("\(value) km")
    }

}

extension MapViewController : CLLocationManagerDelegate {
    
    // When the user first launches the app, the map view may attempt to fetch the current location before the app is authorized to use Location Services. Enable the current location only after the app is authorized.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            if self.locationManager.location != nil {
                centerMapOnLocation(self.locationManager.location, distance: self.distanceSlider.value)
            }
        }
    }
}

let MERCATOR_OFFSET : Double = 268435456
let MERCATOR_RADIUS : Double = 85445659.44705395

extension MKMapView {

    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = centerLocation.distanceFromLocation(topCenterLocation)
        return radius // in Meters
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerCoor = self.centerCoordinate
        return centerCoor
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.convertPoint(CGPointMake(self.frame.size.width / 2.0, 0), toCoordinateFromView: self)
        return topCenterCoor
    }
    
    // Return the current map zoomLevel equivalent
    func getZoomLevel() -> Double {
        let reg = self.region // the current visible region
        let span = reg.span // the deltas
        let centerCoordinate = reg.center // the center in degrees
        
        // Get the left and right most lonitudes
        let leftLongitude = (centerCoordinate.longitude-(span.longitudeDelta/2))
        let rightLongitude = (centerCoordinate.longitude+(span.longitudeDelta/2))
        let mapSizeInPixels = self.bounds.size; // the size of the display window

        // Get the left and right side of the screen in fully zoomed-in pixels
        let leftPixel = longitudeToPixelSpaceX(leftLongitude)
        let rightPixel = longitudeToPixelSpaceX(rightLongitude)
        // The span of the screen width in fully zoomed-in pixels
        let pixelDelta = abs(rightPixel - leftPixel)

        // The ratio of the pixels to what we're actually showing
        let zoomScale = Double(mapSizeInPixels.width) / pixelDelta
        // Inverse exponent
        let zoomExponent = log2(zoomScale)
        // Adjust our scale
        let zoomLevel = zoomExponent + 20
        
        return zoomLevel;
    }
    
    func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0)
    }

    func latitudeToPixelSpaceY(latitude: Double) -> Double {
        let x = (1 + sinf(Float(latitude) * Float(M_PI) / 180.0)) / (1 - sinf(Float(latitude) * Float(M_PI) / 180.0))
        let a = logf(x) / 2.0
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * Double(a))
    }

    func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
    }

    func pixelSpaceYToLatitude(pixelY: Double) -> Double  {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
    }
}
