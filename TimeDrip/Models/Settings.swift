//
//  Settings.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/3/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.

import Foundation

let disabledAlways: [SettingsRow] = [.styleSet]
let disabledInPrefsMode: [SettingsRow] = [.name, .timeSet]
let disabledInSingleUseMode: [SettingsRow] = [.name]

enum SettingsRow: Int {
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
//        case .shaded:
//            return "saveNoticeCell"
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
//        case .shaded:
//            return "saveNoticeCell"
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
        var disabledInMode: [SettingsRow] = []
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

    static func all() -> [SettingsRow] {
        var settingsArray : [SettingsRow] = []
        for i in 0...SettingsRow.count-1 {
            settingsArray.append(SettingsRow(rawValue: i)!)
        }
        return settingsArray
    }

    static func defaultPrefs() -> [SettingsRow] {
        var settingsArray : [SettingsRow] = []
        for i in 0...SettingsRow.count-1 {
            let settingRow = SettingsRow(rawValue: i)!
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

}
