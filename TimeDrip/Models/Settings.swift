//
//  Settings.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/3/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.

import Foundation

let disabledAlways: [TimerSettingsRow] = [.styleSet]
let disabledInPrefsMode: [TimerSettingsRow] = [.name, .timeSet]
let disabledInSingleUseMode: [TimerSettingsRow] = [.name]

enum TimerSettingsRow: Int {
    case name
    case styleSet
    case stylePicker
    case timeSet
    case timePicker
    case autoStart
    case pausable
    case cancelable
    case color
    case soundSet
    case soundPicker
    case loopAudio
    case overflow

    static let count = 12

    func reuseIdent () -> String {
        switch self {
        case .timeSet:
            return "detailCell"
        case .timePicker:
            return "pickerCell"
        case .soundSet:
            return "detailCell"
        case .soundPicker:
            return "pickerCell"
        case .styleSet:
            return "detailCell"
        case .stylePicker:
            return "pickerCell"
        case .name:
            return "titleCell"
        case .autoStart:
            return "toggleCell"
        case .color:
            return "colorCell"
        case .pausable:
            return "toggleCell"
        case .cancelable:
            return "toggleCell"
        case .loopAudio:
            return "toggleCell"
        default:
            return "errorCell"
        }
    }

    func nibName () -> String {
        switch self {
        case .timeSet:
            return "DetailCell"
        case .timePicker:
            return "PickerCell"
        case .soundSet:
            return "DetailCell"
        case .soundPicker:
            return "PickerCell"
        case .styleSet:
            return "DetailCell"
        case .stylePicker:
            return "PickerCell"
        case .name:
            return "TitleCell"
        case .autoStart:
            return "ToggleCell"
        case .color:
            return "ColorSampleTableViewCell"
        case .pausable:
            return "ToggleCell"
        case .cancelable:
            return "ToggleCell"
        default:
            return "errorCell"
        }
    }

    func order() -> Int {
        return self.rawValue
    }

    func disabled() -> Bool {
        return disabledAlways.contains(self)
    }

    func disabled(mode: Mode) -> Bool {
        var disabledInMode: [TimerSettingsRow] = []
        switch mode {
        case .singleUse:
            disabledInMode = disabledInSingleUseMode
        case .prefs:
            disabledInMode = disabledInPrefsMode
        default:
            ()
        }
        return disabledAlways.contains(self) || disabledInMode.contains(self)
    }

    func enabled() -> Bool {
        return !(disabledAlways.contains(self))
    }

    func enabled(mode: Mode) -> Bool {
        return !disabled(mode: mode)
    }

    func hasDefault() -> Bool {
        switch self {
        case .autoStart, .color, .pausable, .cancelable:
            return true
        default:
            return false
        }
    }

    static func all() -> [TimerSettingsRow] {
        var settingsArray : [TimerSettingsRow] = []
        for i in 0...TimerSettingsRow.count-1 {
            settingsArray.append(TimerSettingsRow(rawValue: i)!)
        }
        return settingsArray
    }

    static func defaultPrefs() -> [TimerSettingsRow] {
        var settingsArray : [TimerSettingsRow] = []
        for i in 0...TimerSettingsRow.count-1 {
            let settingRow = TimerSettingsRow(rawValue: i)!
            if settingRow.hasDefault() {
                settingsArray.append(settingRow)
            }
        }
        return settingsArray
    }

    func specialCellType() -> Any? {
        switch self {
        case .color:
            return ColorSampleTableViewCell.self
        default:
            return nil
        }
    }

    private func debugRemindMeToUpdateCount() {
        /**
         This function should never be run.
         The whole point of it is to exist to throw a flag
         when the cases of the enum are changed.
         Do not update the switch statement in this function
         until after the count is updated.
         */


        var x = 0 // Just sticking this here to number lines with.
        switch self {
        case .timeSet:
            x = 1
        case .timePicker:
            x = 2
        case .soundSet:
            x = 3
        case .soundPicker:
            x = 4
        case .styleSet:
            x = 5
        case .stylePicker:
            x = 6
        case .name:
            x = 7
        case .autoStart:
            x = 8
        case .color:
            x = 9
        case .pausable:
            x = 10
        case .cancelable:
            x = 11
        case .loopAudio:
            x = 12
        case .overflow:
            x = 13 // overflow is here for debug crash-proofing
                   // Set count to one less than overflow value
        }
        print(x) // No reason to do this. Just wanted to.
        }
}

let disabledAppLevelSettings: [AppSettingsRow] = []

enum AppSettingsRow: Int {
    case startOnSavedList
    case darkForLightColors
    case swipeLeftForEdit
    case setTimerDefaults
    case viewCredits
    case resetAllSettings
    case overflow


    static let count = 6

    func reuseIdent () -> String {
        switch self {
        case .startOnSavedList:
            return "toggleCell"
        case .darkForLightColors:
            return "toggleCell"
        case .swipeLeftForEdit:
            return "toggleCell"
        case .setTimerDefaults:
            return "detailCell"
        case .viewCredits:
            return "detailCell"
        case .resetAllSettings:
            return "detailCell"
        default:
            return "errorCell"
        }
    }

    func nibName () -> String {
        switch self {
        default:
            return ""
        }
    }

    func order() -> Int {
        return self.rawValue
    }

    func disabled() -> Bool {
        return disabledAppLevelSettings.contains(self)
    }


    func enabled() -> Bool {
        return !(disabledAppLevelSettings.contains(self))
    }

    static func all() -> [AppSettingsRow] {
        var settingsArray : [AppSettingsRow] = []
        for i in 0...AppSettingsRow.count-1 {
            settingsArray.append(AppSettingsRow(rawValue: i)!)
        }
        return settingsArray
    }

    private func debugRemindMeToUpdateCount() {
        /**
         This function should never be run.
         The whole point of it is to exist to throw a flag
         when the cases of the enum are changed.
         Do not update the switch statement in this function
         until after the count is updated.
         */


        var x = 0 // Just sticking this here to number lines with.
        switch self {
        case .startOnSavedList:
            x = 1
        case .darkForLightColors:
            x = 2
        case .viewCredits:
            x = 3
        case .setTimerDefaults:
            x = 4
        case .resetAllSettings:
            x = 5
        case .swipeLeftForEdit:
            x = 6
        case .overflow:
            x = 0 //
                  // Set count to value before overflow
        }
        print(x)
    }
}

class Defaults {
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

        // Ints
        static let timerStyle = "timerStyle"

        static let allDefaults : [String] = [colorHex, alertSound, pausable, cancelable, autoStart, loopAudio]
    }

    struct AppDefaults {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let startOnSavedList = "startOnSavedList"
        static let darkForLightColors = "darkForLightColors"
        static let swipeLeftForEdit = "swipeLeftForEdit"

        static let allDefaults : [String] = [hasLaunchedBefore, startOnSavedList, darkForLightColors, swipeLeftForEdit]
        static let allClearable : [String] = [startOnSavedList, darkForLightColors, swipeLeftForEdit]
    }

    class func register() {
        let defaults: [String : Any] = [
            TimerDefaults.colorHex : "",
            TimerDefaults.alertSound : "blank",
            TimerDefaults.pausable : false,
            TimerDefaults.cancelable : true,
            TimerDefaults.autoStart : true,
            TimerDefaults.loopAudio : false,
            AppDefaults.startOnSavedList : false,
            AppDefaults.darkForLightColors : true,
            AppDefaults.swipeLeftForEdit : true,
            ]
        UserDefaults.standard.register(defaults: defaults)
    }

    func clearAll() {
        // For debugging purposes only. Probably.
        var keys = [ "pausable", "cancelable", "autoStart", "loopAudio","color", "hexcolor",                     "style","alertSound","soundName","soundFile","useStartScreen"]
        keys.append(contentsOf: TimerDefaults.allDefaults)
        keys.append(contentsOf: AppDefaults.allDefaults)
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func clearTimerDefaults() {
        for key in TimerDefaults.allDefaults {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func clearAppDefaults() {
        for key in AppDefaults.allClearable {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
