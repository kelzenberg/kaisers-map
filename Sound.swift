//
//  Sound.swift
//  Kaisers Map
//
//  Created by Steffen Ansorge on 10.07.18.
//  Copyright © 2018 Steffen Ansorge. All rights reserved.
//

import Foundation
import AudioToolbox

class Sound {
    static var internalInstance: Sound?
    class var instance: Sound {
        get {
            if (internalInstance == nil) {
                internalInstance = Sound()
            }
            return internalInstance!
        }
    }
    
    enum IDs: SystemSoundID {
        case location = 1109
        case tap = 1104
    }
    
    static func notifyBySound(with soundID: IDs) {
        AudioServicesPlaySystemSound(soundID.rawValue)
    }
}
