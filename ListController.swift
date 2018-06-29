//
//  SecondViewController.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 22.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import UIKit
import CoreLocation

class ListController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var itemList: UIStackView!
    
    var manager: CLLocationManager?
    var location: CLLocation?
    var data = Data()
    var rows = [Row]()
    
    struct Row {
        let id: Int
        var uiImage: UIImageView
        let uiLabel: UILabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestAlwaysAuthorization()
        
        collectRows()
        initRegions()

        manager?.startUpdatingLocation()
    }
    
    func collectRows() {
        var counter = 0
        for stackView in itemList.subviews {
            rows.append(
                Row(
                    id: counter,
                    uiImage: stackView.subviews[0] as! UIImageView,
                    uiLabel: stackView.subviews[1] as! UILabel
                )
            )
            let index = data.cycleDict(inc: counter)
            let label = rows[counter].uiLabel
            
            label.text = data.tasks[index]?.desc
            print("Row", counter, "added with description: \"" + label.text! + "\"")
            counter += 1
        }
        print("\nFinished addding rows\nFinal number of Rows: ", rows.count)
    }
    
    func initRegions() {
        for spot in data.tasks {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: spot.value.lat, longitude: spot.value.lon), radius: 1, identifier: String(spot.key))
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager?.startMonitoring(for: region)
        }
    }
    
    func swapIcon(regionID: Int) {
        print("Swap Icon for RegionID:", regionID)
        rows[regionID].uiImage.image = UIImage(named: "finished")!
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        /*let last = locations.last
         let latVal = last?.coordinate.latitude
         let lonVal = last?.coordinate.longitude
         print("\nLat:" + (latVal?.description)!)
         print("Lon:" + (lonVal?.description)!)
         print("**** from locations:")*/
        print("lat: " + (manager.location?.coordinate.latitude.description)! + ", lon: " + (manager.location?.coordinate.longitude.description)! + "\r")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("Entered Region:", Int(identifier)!)
            swapIcon(regionID: Int(identifier)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            print("Exit Region:", Int(region.identifier)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

