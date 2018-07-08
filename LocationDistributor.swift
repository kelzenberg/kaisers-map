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
    var regionViews = [LocationListener]()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        // TODO: Callback, when regions are cleared
        clearRegions()
            print("Monitored regions cleared\nRegion count:", manager.monitoredRegions.count)
        
        initRegions()
            print("Monitored regions:", manager.monitoredRegions.description, "\nMonitored regions count:", manager.monitoredRegions.count)
        
        manager.startUpdatingLocation()
    }
    
    // TODO: maybe use callback & closures for this
    func addLocationListener(listenerView: LocationListener){
        print("Listener for Location added:", listenerView)
        regionViews.append(listenerView)
        print("Listener count:", regionViews.count)
    }
    
    func clearRegions() {
        // clear out all (old) regions
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }
    
    func initRegions() {
        // add new regions
        for spot in data.tasks {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: spot.value.lat, longitude: spot.value.lon), radius: 2, identifier: String(spot.key))
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("     lat: " + (manager.location?.coordinate.latitude.description)! + ", lon: " + (manager.location?.coordinate.longitude.description)!)
        for regionView in regionViews {
            regionView.didUpdateLocation(lastLocation: (locations.last?.coordinate)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor:", region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let regionID = region.identifier
            print("Entered Region:", Int(regionID)!)
            data.tasks[Int(regionID)!]?.visited = true
            for regionView in regionViews {
                regionView.didEnterRegion(regionID: Int(regionID)!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            print("Exit Region:", Int(region.identifier)!)
        }
    }
}

protocol LocationListener {
    func didUpdateLocation(lastLocation: CLLocationCoordinate2D)
    func didEnterRegion(regionID: Int)
}
