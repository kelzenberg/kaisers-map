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

class MapController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, LocationListener {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var trackingBtn: UIButton!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var rotationGestureRecognizer: UIRotationGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let locationDist = LocationDistributor.instance
    let data = Data.instance
    var initialized = false
    var trackingStatus = false
    
    class Marker: NSObject, MKAnnotation {
        let id: Int
        var coordinate: CLLocationCoordinate2D
        var title: String?
        
        static let colorBlue = UIColor(red: 108.0/255.0, green: 174.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        static let colorGreen = UIColor(red: 128.0/255.0, green: 236.0/255.0, blue: 138.0/255.0, alpha: 1.0)
        
        init(id: Int, coordinates: CLLocationCoordinate2D, title: String) {
            self.id = id
            self.coordinate = coordinates
            self.title = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationDist.addLocationListener(listenerView: self)
        
        map.delegate = self
        setUpMarkers()
        
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
        
        trackingBtn.layer.masksToBounds = false
        trackingBtn.layer.cornerRadius = trackingBtn.frame.width / 2

    }
    
    func setUpMarkers() {
        //clean up any possible old annotations
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        for task in data.tasks {
            let marker = Marker(id: task.key, coordinates: CLLocationCoordinate2D(latitude: task.value.lat, longitude: task.value.lon), title: task.value.desc)
            map.addAnnotation(marker)
        }
    }
    
    func setMapViewRegion(coordinates: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinates, 700, 700)
        map.setRegion(viewRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for thisView in views {
            let thisAnnotation = thisView.annotation
            
            for theirAnnotation in mapView.annotations {
                let theirView = mapView.view(for: theirAnnotation) as? MKMarkerAnnotationView
                let theirAnnotation = theirAnnotation as? Marker
                //print("casting worked")
            
                if (theirView != nil && theirAnnotation != nil){
                    //print("correct view/marker type")
                
                    if theirAnnotation!.isEqual(thisAnnotation) {
                        print("correct marker")
                    
                        if (data.tasks[theirAnnotation!.id]?.visited)! {
                            print("Region \(theirAnnotation!.id) was already visited.")
                            theirView!.markerTintColor = Marker.colorGreen
                        } else {
                            theirView!.markerTintColor = Marker.colorBlue
                        }
                        
                    } else {
                        //print("wrong marker")
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // make sure annotation is of type Marker here
        guard let annotation = annotation as? Marker else { return nil }
        // setup variables
        var annotationView = MKMarkerAnnotationView()
        let identifier = "simpleMarker"
        /*
        * map view reuses annotation views that are no longer visible.
        * this checks to see if a reusable annotation view is available
        * before creating a new one
        */
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequeuedView
            dequeuedView.annotation = annotation
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        }
        
        return annotationView
    }
    
    @IBAction func toggleTracking() {
        trackingStatus = !trackingStatus
        trackingBtn.isHidden = trackingStatus
        print("Tracking Status:", trackingStatus)
    }
    
    func setTracking() {
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
    
    @IBAction func userDidChangeMap(_ sender: UIGestureRecognizer) {
        if trackingStatus && sender.state == .ended {
            print(sender.name ?? "No_name_provided", "registered user input on map.")
            toggleTracking()
        }
    }
    
    func didUpdateLocation(lastLocation: CLLocationCoordinate2D) {
        if (!initialized) {
            setMapViewRegion(coordinates: lastLocation)
            initialized = true
        }
        setTracking()
    }

    func didEnterRegion(regionID: Int) {
        for annotation in map.annotations {
            guard let annotation = annotation as? Marker else { continue }
            if (annotation.id == regionID) {
                let tempAnnotation = annotation
                map.removeAnnotation(annotation)
                map.addAnnotation(tempAnnotation)
                print("Annotation \(annotation.id) removed & \(tempAnnotation.id) added again")
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // make another gesture recognizer work with recognizers in MKMapView
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

