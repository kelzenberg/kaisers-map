//
//  Data.swift
//  Kaisers Waypoints
//
//  Created by Steffen Ansorge on 01.06.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import CoreLocation

class Data {
    
    var tasks = [
        0: Spots(desc: "Tageszeitung kaufen", lat: 52.505546, lon: 13.332595),
        1: Spots(desc: "Neues Sudoku erfragen", lat: 52.504947, lon: 13.338505),
        2: Spots(desc: "Katzenfutter kaufen", lat: 52.503018, lon: 13.350213),
        3: Spots(desc: "Currwurst-Atze grüßen", lat: 52.514371, lon: 13.35106),
        4: Spots(desc: "Die Landschaft genießen", lat: 52.517053, lon: 13.354666),
        5: Spots(desc: "Über das Leben nachdenken", lat: 52.517325, lon: 13.366123),
        6: Spots(desc: "Eine App programmieren", lat: 52.517789, lon: 13.377094)
    ]
    
    func cycleDict(inc: Int) -> Int{
        var pointer = inc
        if (pointer < 0 || pointer >= tasks.count){
            pointer = pointer % tasks.count
        }
        print(
            "\nSize:", tasks.count,
            "&", "Increment:", inc,
            "-> new Slot:", pointer
        )
        return pointer
    }
}

struct Spots {
    let desc: String
    let lat: Double
    let lon: Double
}
