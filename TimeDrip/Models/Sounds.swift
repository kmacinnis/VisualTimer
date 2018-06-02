//
//  Sounds.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 5/27/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import Foundation

class Sounds {
    static let soundArray = [
        ["name":"Alert Sound: Buzzer", "file":"alertsound-buzzer"],
        ["name":"Alert Sound: Horn", "file":"alertsound-horn"],
        ["name":"Alert Sound: Invasion", "file":"alertsound-invasion"],
        ["name":"Alert Sound: Permission To Panic", "file":"alertsound-permission-to-panic"],
        ["name":"Alert Sound: Schoolbell", "file":"alertsound-schoolbell"],
        ["name":"Ancient Announcement", "file":"ancient-announcement"],
        ["name":"Born Sovy", "file":"born-sovy"],
        ["name":"Dark Magic", "file":"dark-magic"],
        ["name":"Dilemma", "file":"dilemma"],
        ["name":"Dolphin Ride", "file":"dolphin-ride"],
        ["name":"Drifting Through Space", "file":"drifting-through-space"],
        ["name":"Endless Corridor", "file":"endless-corridor"],
        ["name":"Fairy Glen", "file":"fairy-glen"],
        ["name":"Game Groove", "file":"game-groove"],
        ["name":"Jaraxe Guitar", "file":"jaraxe-guitar"],
        ["name":"Lemon Symphony", "file":"lemon-symphony"],
        ["name":"Mellow Citrus", "file":"mellow-citrus"],
        ["name":"Mouth Music", "file":"mouth-music"],
        ["name":"Music Box", "file":"music-box"],
        ["name":"Orange Modern", "file":"orange-modern"],
        ["name":"Persistant Trooper", "file":"persistant-trooper"],
        ["name":"Rocky Comet", "file":"rocky-comet"],
        ["name":"Rumma Beat", "file":"rumma-beat"],
        ["name":"Stinky Grove", "file":"stinky-grove"],
        ["name":"Theremin Quartet", "file":"theremin-quartet"],
        ["name":"Trapped In A Dream", "file":"trapped-in-a-dream"],
        ["name":"Upbeat Hero", "file":"upbeat-hero"],
    ]

    static func getIndex(filename: String) -> Int? {
        for i in 0...soundArray.count - 1 {
            if soundArray[i]["file"] == filename {
                return i
            }
        }
        return nil
    }

    static func getIndex(name: String) -> Int? {
        for i in 0...soundArray.count {
            if soundArray[i]["name"] == name {
                return i
            }
        }
        return nil
    }

}
