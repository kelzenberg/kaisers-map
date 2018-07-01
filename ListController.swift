//
//  ListController.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 22.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import UIKit
import CoreLocation

class ListController: UIViewController, receiveLocationInfo {
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
        collectRows()
        locationDist.addListener(regionView: self)
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
    
    func didUpdateLocation(didUpdateLocations locations: [CLLocation]) {
        //
    }
    
    func didEnterRegion(regionID: Int) {
        print("Swap Icon for RegionID:", regionID)
        rows[regionID].uiImage.image = UIImage(named: "finished")!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

