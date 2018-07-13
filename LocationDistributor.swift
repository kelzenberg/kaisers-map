//
//  LocationDistributor.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 29.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

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
    let center = UNUserNotificationCenter.current()
    let data = Data.instance
    var listenerViews = [LocationListener]()
    var permitNotification = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                self.permitNotification = true
                print("User denied notifications.")
            }
            if error != nil {
                print("Authorization returned error:\n\((error)!)")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.permitNotification = false
                print("User changed permissions & denied notifications.")
            }
        }
        
        initRegionsAndNotifications()
        
        manager.startUpdatingLocation()
    }
    
    func addLocationListener(for listenerView: LocationListener){
        print("Listener for Location added:", listenerView)
        listenerViews.append(listenerView)
        print("Listener count:", listenerViews.count)
    }
    
    func clearRegions() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }
    
    func initRegionsAndNotifications() {
        // clear out all (old) regions first
        clearRegions()
        print("Monitored regions cleared\nRegion count: \(manager.monitoredRegions.count)")
        // add new regions & notification
        for spot in data.tasks {
            let identifier = String(spot.key)
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: spot.value.lat, longitude: spot.value.lon), radius: 2, identifier: identifier )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            let notification = UNMutableNotificationContent()
            notification.title = spot.value.desc
            notification.body = "\"Just do it!\" – Shia LaBeouf"
            let tempRegion = CLCircularRegion(center: region.center, radius: 20, identifier: region.identifier)
            let trigger = UNLocationNotificationTrigger(region: tempRegion, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
            
            center.add(request) { (error) in
                if error != nil {
                    print("Adding Notification returned error:\n\((error)!)")
                }
            }
            print("Center added request: \(request.content.title)")
            manager.startMonitoring(for: region)
        }
        
        print("Monitored regions: \(manager.monitoredRegions.description)\nMonitored regions count: \(manager.monitoredRegions.count)")
        center.getPendingNotificationRequests { (requests) in
            print("Notifications pending: \(requests.count)")
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("     lat: " + (manager.location?.coordinate.latitude.description)! + ", lon: " + (manager.location?.coordinate.longitude.description)!)
        for regionView in listenerViews {
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
            Sound.notifyBySound(with: Sound.IDs.location)
            for regionView in listenerViews {
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
