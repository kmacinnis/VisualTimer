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
    case music = 1
    case garden = 2
    case sand = 3
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

    override static func primaryKey() -> String? {
        return "id"
    }
}

//class SimpleTimer: Object {
//    @objc dynamic var savedTimer: SavedTimer?
//}

