//
//  StandardUserDefaults.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/8/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import Foundation

class AppDefaults {
    // The purpose of this is to minimize typos (or accidentally having soundName vs soundFile vs alertSound)
    // This is not its final form
    // reference for ideas: https://medium.com/swift-programming/swift-userdefaults-protocol-4cae08abbf92

    struct TimerDefaults {
        // Strings
        static let colorHex = "colorHex"
        static let alertSound = "alertSound"

        // Bools
        static let pausable = "pausable"
        static let cancelable = "cancelable"
        static let autoStart = "autoStart"
        static let loopAudio = "loopAudio"

        let all : [String] = [colorHex, alertSound, pausable, cancelable, autoStart, loopAudio]

    }

    struct AppLevel {
        static let hasLaunchedBefore = "hasLaunchedBefore"

        static let useStartScreen = "useStartScreen"
        static let darkForLightColors = "darkForLightColors"
    }

    func register() {
        let defaults: [String : Any] = [
            TimerDefaults.colorHex : "",
            TimerDefaults.alertSound : "blank",
            TimerDefaults.pausable : false,
            TimerDefaults.cancelable : true,
            TimerDefaults.autoStart : true,
            TimerDefaults.loopAudio : false,

            AppLevel.useStartScreen : true,
            AppLevel.darkForLightColors : true,
            ]
        UserDefaults.standard.register(defaults: defaults)
    }


    func clearAll() {
        // For debugging purposes only. Probably.
        let keys = [ "pausable",
                     "cancelable",
                     "autoStart",
                     "loopAudio",
                     "color", "hexcolor",
                     "style",
                     "alertSound","soundName","soundFile",
                     TimerDefaults.autoStart, TimerDefaults.cancelable,
                     TimerDefaults.loopAudio, TimerDefaults.pausable,

                     TimerDefaults.colorHex, TimerDefaults.alertSound,
                     ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }


}



