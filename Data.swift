//
//  Data.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 01.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import CoreLocation

class Data {
    static var internalInstance: Data?
    class var instance: Data {
        get {
            if (internalInstance == nil) {
                internalInstance = Data()
            }
            return internalInstance!
        }
    }
    
    var tasks = [
        0: Spot(desc: "Tageszeitung kaufen", lat: 52.50503,  lon: 13.334827, visited: false),
        1: Spot(desc: "Neues Sudoku erfragen", lat: 52.504947, lon: 13.338505, visited: false),
        2: Spot(desc: "Katzenfutter kaufen", lat: 52.503018, lon: 13.350213, visited: false),
        3: Spot(desc: "Currwurst-Atze grüßen", lat: 52.514371, lon: 13.35106, visited: false),
        4: Spot(desc: "Die Landschaft genießen", lat: 52.517053, lon: 13.354666, visited: false),
        5: Spot(desc: "Über das Leben nachdenken", lat: 52.517325, lon: 13.366123, visited: false),
        6: Spot(desc: "Eine App programmieren", lat: 52.517789, lon: 13.377094, visited: false)
    ]
    
    func cycleDict(inc: Int) -> Int{
        var pointer = inc
        if (pointer < 0 || pointer >= tasks.count){
            pointer = pointer % tasks.count
        }
        print(
            "\n(Size:", tasks.count,
            ")", "External Slot:", inc,
            "=> Data Slot:", pointer
        )
        return pointer
    }
    
    func setSpotVisited(regionID: Int, state: Bool){
        
    }
}

struct Spot {
    let desc: String
    let lat: Double
    let lon: Double
    var visited: Bool
}
