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
//TODO: * Confirm on reset to defaults


class SettingsViewController: UITableViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    var darkSwitch: UISwitch?
    var startSwitch: UISwitch?
    var swipeSwitch: UISwitch?
    var origStartValue = true
    var origDarkValue = true
    var origSwipeValue = true

    override func viewDidLoad() {
        super.viewDidLoad()

        origDarkValue = UserDefaults.standard.bool(forKey: Defaults.AppDefaults.darkForLightColors)
        origStartValue = UserDefaults.standard.bool(forKey: Defaults.AppDefaults.startOnSavedList)
        origSwipeValue = UserDefaults.standard.bool(forKey: Defaults.AppDefaults.swipeLeftForEdit)

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
            case .startOnSavedList:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ToggleCell
                cell.toggleLabel.text = "Go to saved timer list on open"
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
            case .swipeLeftForEdit:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ToggleCell
                cell.toggleLabel.text = "Swipe left on saved timer list to edit or delete"
                swipeSwitch = cell.toggleSwitch
                swipeSwitch?.isOn = origSwipeValue
                swipeSwitch?.addTarget(self, action: #selector(swipeSwitchChanged), for: UIControl.Event.allTouchEvents)

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
        case .setTimerDefaults:
            coordinator?.pushDefaultSettings()
        case .viewCredits:
            coordinator?.pushCredits()
        case .resetAllSettings:
            let def = Defaults()
            def.clearAppDefaults()
            def.clearTimerDefaults()
            tableView.reloadData()
        default:
            ()
        }
    }

    //MARK:- Switch handling

    @objc func darkSwitchChanged() {
        UserDefaults.standard.set(darkSwitch?.isOn, forKey: Defaults.AppDefaults.darkForLightColors)
    }
    @objc func startSwitchChanged() {
        UserDefaults.standard.set(startSwitch?.isOn, forKey: Defaults.AppDefaults.startOnSavedList)
    }

    @objc func swipeSwitchChanged() {
        UserDefaults.standard.set(swipeSwitch?.isOn, forKey: Defaults.AppDefaults.swipeLeftForEdit)
    }

}
