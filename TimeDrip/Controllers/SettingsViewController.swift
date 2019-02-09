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
    var sectionList: [String] {
        return [appLevelSettings, defaultSettings, credits]
    }

    let appLevelSettingsList = ["Show start screen", "Dark background for light colors"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "toggleCell")
        tableView.register(UINib(nibName: "DisabledCell", bundle: nil), forCellReuseIdentifier: "disabledCell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionList[section] {
        case appLevelSettings:
            return appLevelSettingsList.count
        case defaultSettings:
            return 1
        case credits:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch sectionList[indexPath.section] {
        case appLevelSettings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! ToggleCell
            cell.toggleLabel.text = appLevelSettingsList[indexPath.row]
            return cell
        case defaultSettings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
            cell.title.text = "Set timer defaults"
            cell.detail.text = ">"
            return cell
        case credits:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
            cell.title.text = "View acknowledgements"
            cell.detail.text = ">"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell", for: indexPath) as! DisabledCell
            return cell
        }

    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sectionList[indexPath.section] {
        case appLevelSettings:
            ()
        //TODO: add description modal when row is tapped? Maybe?
        case defaultSettings:
            coordinator?.pushDefaultSettings()
        case credits:
            ()
        default:
            ()
        }
    }


    //TODO: - Add credits
    // Gear by Reed Enger from the Noun Project
    // Sources for sounds are listed in sounds/details
}
