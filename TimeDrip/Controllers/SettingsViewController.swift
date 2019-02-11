//
//  SettingsViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 5/15/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

//TODO: * Figure out and add log messages
//TODO: * Add modals describing settings on tap
//TODO: * Make view credits work
        //TODO: - Add credits
        // Gear by Reed Enger from the Noun Project
        // Sources for sounds are listed in sounds/details
//TODO: * Confirm on reset to defaults
//TODO: * Make App-Level preferences actually do something.


class SettingsViewController: UITableViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    var darkSwitch: UISwitch?
    var startSwitch: UISwitch?
    var origStartValue = true
    var origDarkValue = true



    override func viewDidLoad() {
        super.viewDidLoad()

        origDarkValue = UserDefaults.standard.bool(forKey: Defaults.AppDefaults.darkForLightColors)
        origStartValue = UserDefaults.standard.bool(forKey: Defaults.AppDefaults.useStartScreen)

        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "toggleCell")
        tableView.register(UINib(nibName: "DisabledCell", bundle: nil), forCellReuseIdentifier: "disabledCell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSettingsRow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let setting = AppSettingsRow(rawValue: indexPath.row) {
            switch setting {
            case .useStartScreen:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ToggleCell
                cell.toggleLabel.text = "Show start screen"
                startSwitch = cell.toggleSwitch
                startSwitch?.isOn = origStartValue
                startSwitch?.addTarget(self, action: #selector(startSwitchChanged), for: UIControl.Event.allTouchEvents)

                return cell
            case .darkForLightColors:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ToggleCell
                cell.toggleLabel.text = "Dark background for light colors"
                darkSwitch = cell.toggleSwitch
                cell.toggleSwitch.isOn = origDarkValue
                darkSwitch?.addTarget(self, action: #selector(darkSwitchChanged), for: UIControl.Event.allTouchEvents)

                return cell
            case .setTimerDefaults:
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
                cell.title.text = "Set timer defaults"
                cell.detail.text = ">"
                return cell
            case .viewCredits:
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
                cell.title.text = "View acknowledgements"
                cell.detail.text = ">"
                return cell
            case .resetAllSettings:
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
                cell.title.text = "Reset to default settings"
                cell.detail.text = " "
                return cell
            case .overflow:
                let cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell", for: indexPath) as! DisabledCell
                //TODO: log some kind of warning here
                return cell

            } // end switch
        } else { // if setting is nil
            let cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell", for: indexPath) as! DisabledCell
            //TODO: log some kind of warning here
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = AppSettingsRow(rawValue: indexPath.row)!
        switch setting {
        case .useStartScreen:
            ()
        case .darkForLightColors:
            ()
        case .setTimerDefaults:
            coordinator?.pushDefaultSettings()
        case .viewCredits:
            ()
        case .resetAllSettings:
            let def = Defaults()
            def.clearAppDefaults()
            def.clearTimerDefaults()
            tableView.reloadData()
        case .overflow:
            ()
            //TODO: Log warning here
        }
    }

    //MARK:- Switch handling

    @objc func darkSwitchChanged() {
        UserDefaults.standard.set(darkSwitch?.isOn, forKey: Defaults.AppDefaults.darkForLightColors)
    }
    @objc func startSwitchChanged() {
        UserDefaults.standard.set(startSwitch?.isOn, forKey: Defaults.AppDefaults.useStartScreen)
    }


}
