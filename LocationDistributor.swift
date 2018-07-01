//
//  LocationDistributor.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 29.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import Foundation
import CoreLocation

class LocationDistributor: NSObject, CLLocationManagerDelegate {
    static var internalInstance: LocationDistributor?
    class var instance: LocationDistributor {
        get {
            if (internalInstance == nil) {
                internalInstance = LocationDistributor()
            }
            return internalInstance!
        }
    }
    
    let manager = CLLocationManager()
    let data = Data.instance
    var regionViews = [receiveLocationInfo]()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        initRegions()
        
        manager.startUpdatingLocation()
    }
    
    // TODO: vielleicht als Callback und Closure von View dann bekommen + merken und das Closure dann zum richtigen Zeitpunkt ausführen
    func addListener(regionView: receiveLocationInfo){
        print("Listener for Location added:", regionView)
        regionViews.append(regionView)
    }
    
    func initRegions() {
        for spot in data.tasks {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: spot.value.lat, longitude: spot.value.lon), radius: 1, identifier: String(spot.key))
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("     lat: ", (manager.location?.coordinate.latitude.description)!, " lon: ", (manager.location?.coordinate.longitude.description)!)
        for regionView in regionViews {
            regionView.didUpdateLocation(didUpdateLocations: locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("Entered Region:", Int(identifier)!)
            for regionView in regionViews {
                regionView.didEnterRegion(regionID: Int(identifier)!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            print("Exit Region:", Int(region.identifier)!)
        }
    }
}

protocol receiveLocationInfo {
    func didEnterRegion(regionID: Int)
    func didUpdateLocation(didUpdateLocations locations: [CLLocation])
}
