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
    var markerViews = [MKMarkerAnnotationView]()
    var initialized = false
    var trackingStatus = false
    
    class Marker: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        let id: Int
        var title: String? {
            return String(id)
        }
        let subtitle: String?
        
        init(coordinates: CLLocationCoordinate2D, id: Int, description subtitle: String) {
            self.coordinate = coordinates
            self.id = id
            self.subtitle = subtitle
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

    }
    
    func setUpMarkers() {
        for task in data.tasks {
            let marker = Marker(coordinates: CLLocationCoordinate2D(latitude:  task.value.lat, longitude:  task.value.lon), id: task.key, description: task.value.desc)
            markerViews.append(MKMarkerAnnotationView())
            map.addAnnotation(marker)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // make sure annotation is of type Marker here
        guard let annotation = annotation as? Marker else { return nil }
        
        var annotationView = MKMarkerAnnotationView()
        let identifier = "simpleMarker"
        // map view reuses annotation views that are no longer visible.
        // this checks to see if a reusable annotation view is available before creating a new one
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequeuedView
            dequeuedView.annotation = annotation
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        }
        markerViews[annotation.id] = annotationView
        return annotationView
    }
    
    @IBAction func toggleTracking() {
        trackingStatus = !trackingStatus
        trackingBtn.isHidden = trackingStatus
        print("Tracking Status:", trackingStatus)
    }
    
    @IBAction func userDidChangeMap(_ sender: UIGestureRecognizer) {
        if trackingStatus && sender.state == .ended {
            print(sender.name ?? "No_name_provided", "registered user input on map.")
            toggleTracking()
        }
    }
    
    func setMapViewRegion(coordinates: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinates, 700, 700)
        map.setRegion(viewRegion, animated: true)
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
    
    func didUpdateLocation(lastLocation: CLLocationCoordinate2D) {
        if (!initialized) {
            setMapViewRegion(coordinates: lastLocation)
            initialized = true
        }
        setTracking()
    }

    func didEnterRegion(regionID: Int) {
        for marker in markerViews {
            if marker.annotation?.title == String(regionID) {
                marker.markerTintColor = UIColor.cyan
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

