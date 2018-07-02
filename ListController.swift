//
//  ListController.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 22.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import UIKit
import CoreLocation

class ListController: UIViewController, LocationListener {
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
        
        locationDist.addLocationListener(listenerView: self)
        
        collectRows()
        //print(locationDist.manager.monitoredRegions)
    }
    
    func collectRows() {
        var rowIndex = 0
        for stackView in itemList.subviews {
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
    
    func didUpdateLocation(didUpdateLocations locations: [CLLocation]) {
        //print("Location updated: LIST")
    }
    
    func didEnterRegion(regionID: Int) {
        print("Swap icon for Region:", regionID)
        // TODO: animate transition between images
        rows[regionID].uiImage.image = UIImage(named: "finished")!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

