//
//  StandardUserDefaults.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/8/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import Foundation

class Defaults: UserDefaults {
    // The purpose of this is to minimize typos (or accidentally having soundName vs soundFile vs alertSound)
    // This is not its final form
    // reference for ideas: https://medium.com/swift-programming/swift-userdefaults-protocol-4cae08abbf92

    struct Account {
        let isUserLoggedIn = "isUserLoggedIn"
    }

    struct Switches {
        static let pausable = "pausable"
        static let cancelable = "cancelable"
        static let autoStart = "autoStart"
        static let loopAudio = "loopAudio"
    }

    struct Settings {
        static let colorHex = "colorHex"
        static let alertSound = "alertSound"
    }


    func clear() {
        // For debugging purposes only. Probably.
        let keys = [ "pausable",
                     "cancelable",
                     "autoStart",
                     "loopAudio",
                     "color", "hexcolor",
                     "style",
                     "alertSound","soundName","soundFile",
                     Switches.autoStart, Switches.cancelable, Switches.loopAudio, Switches.pausable,
                     Settings.colorHex, Settings.alertSound,
                     ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }


}



