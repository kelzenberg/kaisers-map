//
//  MapController.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 22.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapController: UIViewController, UIGestureRecognizerDelegate, LocationListener {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var trackingBtn: UIButton!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var rotationGestureRecognizer: UIRotationGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let locationDist = LocationDistributor.instance
    //let data = Data.instance
    var trackingStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationDist.addLocationListener(listenerView: self)
        
        panGestureRecognizer.delegate = self
        panGestureRecognizer.name = "Pan Recognizer"
        
        pinchGestureRecognizer.delegate = self
        pinchGestureRecognizer.name = "Pinch Recognizer"
        
        rotationGestureRecognizer.delegate = self
        rotationGestureRecognizer.name = "Rotate Recognizer"
        
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.name = "Tap Recognizer"
        
        map.addGestureRecognizer(panGestureRecognizer)
        map.addGestureRecognizer(pinchGestureRecognizer)
        map.addGestureRecognizer(rotationGestureRecognizer)
        map.addGestureRecognizer(tapGestureRecognizer)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(locationDist.getLastLocation(), 700, 700)
        map.setRegion(viewRegion, animated: true)
    }
    
    @IBAction func toggleTracking() {
        trackingStatus = !trackingStatus
        trackingBtn.isHidden = trackingStatus
        print("Tracking Status:", trackingStatus)
    }
    
    @IBAction func userDidMoveMap(_ sender: UIGestureRecognizer) {
        if trackingStatus && sender.state == .ended {
            print(sender.name ?? "No_name_provided", "registered user input on map.")
            toggleTracking()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // make another gesture recognizer work with recognizers in MKMapView
        return true
    }
    
    func didUpdateLocation(didUpdateLocations locations: [CLLocation]) {
        //print("Tracking Mode:", map.userTrackingMode.rawValue)
        //print("Location updated: MAP")
        
        if trackingStatus {
            // start tracking user's position
            if (map.userTrackingMode == .follow) {
                return
            }
            map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        } else {
            // stop tracking user's position
            if (map.userTrackingMode == .none) {
                return
            }
            map.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
        }
    }

    func didEnterRegion(regionID: Int) {
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

