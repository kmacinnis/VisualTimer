//
//  SavedTimer.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/23/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//


import Foundation
import RealmSwift

class SavedTimer: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var minutesSet: Int = 5
    @objc dynamic var hexColor: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var sortOrder: Int = 99
}

