//
//  ListController.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 22.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ListController: UIViewController, UNUserNotificationCenterDelegate, LocationListener {
    @IBOutlet weak var itemList: UIStackView!
    
    let locationDist = LocationDistributor.instance
    let data = Data.instance
    var rows = [Row]()
    
    struct Row {
        let id: Int
        var uiImage: UIImageView
        let uiLabel: UILabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationDist.addLocationListener(for: self)
        
        UNUserNotificationCenter.current().delegate = self
        
        setUpRows()
        //print(locationDist.manager.monitoredRegions)
    }
    
    func setUpRows() {
        var rowIndex = 0
        for stackView in itemList.subviews {
            if (stackView.tag == 1) {
                break
            }
            rows.append(
                Row(
                    id: rowIndex,
                    uiImage: stackView.subviews[0] as! UIImageView,
                    uiLabel: stackView.subviews[1] as! UILabel
                )
            )
            let dataIndex = data.cycleDict(inc: rowIndex)
            let row = rows[rowIndex]
            let task = data.tasks[dataIndex]
            
            row.uiLabel.text = task?.desc
            row.uiImage.image = (task?.visited)! ? UIImage(named: "finished")! : UIImage(named: "waiting")!
            print("Row", rowIndex, "should have description: \"" + (task?.desc)! + "\"")
            print("and was visited:", task?.visited ?? "no Bool")
            
            rowIndex += 1
        }
        print("\nFinished addding rows\nFinal number of Rows: ", rows.count, "\nNumber of Tasks existent:", data.tasks.count)
    }
    
    func animateSwapImageEvent(for imgView: UIImageView) {
        UIView.animate(withDuration: 0.1, animations: {
            imgView.alpha = 0
        }) { (value: Bool) in
            UIView.animate(withDuration: 0.1, animations: {
                imgView.image = UIImage(named: "finished")!
                imgView.alpha = 1
            })
        }
    }
    
    func didUpdateLocation(lastLocation: CLLocationCoordinate2D) {
        //print("Location updated: LIST")
    }
    
    func didEnterRegion(regionID: Int) {
        if (data.tasks[regionID]?.visited)! {
            print("Swap icon for Region:", regionID)
            animateSwapImageEvent(for: rows[regionID].uiImage)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
        print("Notification should have been seen now.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

