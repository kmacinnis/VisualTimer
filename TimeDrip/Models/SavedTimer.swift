//
//  SavedTimer.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/23/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//


import Foundation
import RealmSwift

// enum must have integer raw values to be stored by realm
@objc enum TimerType: Int {
    case simple = 0
    case hourglass = 1
//    case garden = 2
//    case beach = 3

    static let all = ["Simple Timer", "Hourglass"]
    static let count = all.count

    func display() -> String {
        switch self {
        case .simple:
            return "Simple"
        case .hourglass:
            return "Hourglass"
        }
    }
}


class SavedTimer: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var hoursSet: Int = 0
    @objc dynamic var minutesSet: Int = 0
    @objc dynamic var secondsSet: Int = 0
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var sortOrder: Int = 99
    @objc dynamic var timerType: TimerType = .simple
    @objc dynamic var autoStart: Bool = false
    @objc dynamic var pausable: Bool = false
    @objc dynamic var hexColor: String = ""
    @objc dynamic var cancelable: Bool = true
    @objc dynamic var sound: String = "alertsound-buzzer"
    @objc dynamic var loopAudio: Bool = true

    override static func primaryKey() -> String? {
        return "id"

    }
}

class UnsavedTimer: Object {
    var name: String = ""
    var hoursSet: Int = 0
    var minutesSet: Int = 0
    var secondsSet: Int = 0
    var timerType: TimerType = .simple
    var autoStart: Bool = false
    var pausable: Bool = false
    var color: CGColor = UIColor.blue.cgColor
    var cancelable: Bool = true
    var sound: String = "alertsound-buzzer"
    var loopAudio: Bool = true


}



func convertTimer(savedTimer: SavedTimer) -> UnsavedTimer {
    let unsaved = UnsavedTimer()
    unsaved.name = savedTimer.name
    unsaved.hoursSet = savedTimer.hoursSet
    unsaved.minutesSet = savedTimer.minutesSet
    unsaved.secondsSet = savedTimer.secondsSet
    unsaved.timerType = savedTimer.timerType
    unsaved.autoStart = savedTimer.autoStart
    unsaved.pausable = savedTimer.pausable
    unsaved.color = UIColor.init(hexString: savedTimer.hexColor)?.cgColor ?? UIColor.gray.cgColor
    unsaved.cancelable = savedTimer.cancelable
    unsaved.sound = savedTimer.sound
    unsaved.loopAudio = savedTimer.loopAudio
    return unsaved
}
