//
//  SettingsViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 5/15/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

//TODO: Make this actually work
class SettingsViewController: UITableViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    let appLevelSettings = "App-Level"
    let defaultSettings = "Defaults"
    let credits = "Credits"
    var settingsList: [String] {
        return [appLevelSettings, defaultSettings, credits]
    }

    let appLevelSettingsList = ["Show start screen", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch settingsList[section] {
        case appLevelSettings:
            return appLevelSettings.count
        case defaultSettings:
            return 1
        case credits:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }



    //TODO: - Add credits
    // Gear by Reed Enger from the Noun Project
    // Sources for sounds are listed in sounds/details
}
