//
//  Settings.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/3/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import Foundation

enum SettingsRow: Int {
    case timeSet
    case timePicker
    case autoStart
    case pausable
    case cancelable
    case color
    case shaded
    case name
    case alertSound

    static let count = 8

    func rowIdent () -> String {
        switch self {
        case .timeSet:
            return "timeSetCell"
        case .timePicker:
            return "timePickerCell"
        case .name:
            return "titleCell"
        case .autoStart:
            return "autoStartCell"
        case .color:
            return "colorCell"
        case .shaded:
            return "saveNoticeCell"
        case .pausable:
            return "pausableCell"
        default:
            return "errorCell" // "alertSound"
        }
    }

    func order() -> Int {
        return self.rawValue
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
