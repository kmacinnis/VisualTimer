//
//  EditTimerViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/8/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RappleColorPicker
import RealmSwift

//TODO:
// * change timePickerStyle by swiping picker left/right
// * offer choice of alert sound
// * when editing, should it save & return to list?

enum PickerTag: Int {
    case timePicker
    case soundPicker
}

class EditTimerViewController: UITableViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    enum Mode {
        case add, edit
    }

    var mode: Mode = .add
    var timeText: String = "Tap to set"
    var timerName: String = ""
    var color: UIColor = UIColor.blue
    var timePickerVisible = false
    var timePickerStyle: PickerStyle = .minutesOnly
    var soundPickerVisible: Bool = false
    var hoursSet = 0
    var minutesSet = 0
    var secondsSet = 0
    var origAutoStart = true
    var origPausable = false
    var origCancelable = true

    var nameField: UITextField?
    var autoStartSwitch: UISwitch?
    var pausableSwitch: UISwitch?
    var cancelSwitch: UISwitch?

    var thisTimer: SavedTimer?

    let realm = try! Realm()



    func togglePicker(tag: Int)  {
        switch (PickerTag.init(rawValue: tag))! {
        case .timePicker:
            timePickerVisible = !timePickerVisible
        case .soundPicker:
            soundPickerVisible = !soundPickerVisible
        }
        tableView.reloadData()
    }

    func closePickers() {
        timePickerVisible = false
        soundPickerVisible = false
        tableView.reloadData()
    }

    @objc func nameChanged() {
        timerName = (nameField?.text) ?? ""
        if timerName == "" {
            useBtn.title = "Use Timer"
        } else {
            useBtn.title = "Save & Use Timer"
        }
    }

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        print("Cancel Button Pressed")
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func useBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "useNewTimer", sender: self)
    }

    @IBOutlet weak var useBtn: UIBarButtonItem!


    // MARK: - View Stuff

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ColorSampleTableViewCell", bundle: nil), forCellReuseIdentifier: "colorCell")
        tableView.register(UINib(nibName: "TimePickerCell", bundle: nil), forCellReuseIdentifier: "timePickerCell")
        tableView.register(UINib(nibName: "AutoStartCell", bundle: nil), forCellReuseIdentifier: "autoStartCell")
        tableView.register(UINib(nibName: "TimeSetCell", bundle: nil), forCellReuseIdentifier: "timeSetCell")
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "toggleCell")

        useBtn.isEnabled = (minutesSet > 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsRow.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let setting = SettingsRow(rawValue: indexPath.row) {
            switch setting {
            case .color:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! ColorSampleTableViewCell
                cell.sampleBlock.backgroundColor = color
                return cell
            case .timePicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! TimePickerCell
                cell.picker.dataSource = self
                cell.picker.delegate = self
                cell.picker.tag = PickerTag.timePicker.rawValue
                if mode == .edit {
                    cell.picker.selectRow(minutesSet, inComponent: 0, animated: false)
                }
                //TODO: Attach swipe recognizer to change pickerStyle
                return cell
            case .autoStart:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell") as! ToggleCell
                cell.toggleLabel.text = "Auto-Start Timer:"
                autoStartSwitch = cell.toggleSwitch
                autoStartSwitch?.isOn = origAutoStart
                return cell
            case .pausable:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell") as! ToggleCell
                cell.toggleLabel.text = "Make Timer Pausable:"
                pausableSwitch = cell.toggleSwitch
                pausableSwitch?.isOn = origPausable
                return cell
            case .cancelable:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell") as! ToggleCell
                cell.toggleLabel.text = "Make Timer Cancelable:"
                cancelSwitch = cell.toggleSwitch
                cancelSwitch?.isOn = origCancelable
                return cell
            case .timeSet:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! TimeSetCell
                cell.detail.text = timeText
                return cell
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! TitleCell
                nameField = cell.nameField
                nameField?.text = timerName
                nameField?.addTarget(self, action: #selector(nameChanged), for: UIControlEvents.allEditingEvents)
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: setting.rowIdent(), for: indexPath)
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "errorCell")!
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch SettingsRow(rawValue: indexPath.row)! {
        case .timePicker:
            if timePickerVisible {
                return CGFloat(162)
            } else {
                return CGFloat(0)
            }
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsRow(rawValue: indexPath.row)! {
        case .timeSet:
            togglePicker(tag: PickerTag.timePicker.rawValue)
        case .timePicker:
            print("Touched timePicker")
        case .color:
            RappleColorPicker.openColorPallet { (color, num) in
                self.color = color
                RappleColorPicker.close()
                self.closePickers()

            }
        case .shaded:
            print("timerName: \(timerName)")
            print("nameField: \(String(describing: nameField))")
            print("nameField: \(String(describing: nameField?.text))")
        default:
            closePickers()
        }
    }

    //MARK: - Picker Management

    enum PickerStyle {
        case minutesOnly
        case hoursMinutes
        case minutesSeconds

        mutating func left() {
            switch self {
            case .minutesOnly:
                self = .hoursMinutes
            case .minutesSeconds:
                self = .minutesOnly
            default:
                ()
            }
        }

        mutating func right() {
            switch self {
            case .hoursMinutes:
                self = .minutesOnly
            case .minutesOnly:
                self = .minutesSeconds
            default:
                ()
            }
        }


    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch timePickerStyle {
        case .minutesOnly:
            return 2
        default:
            return 4
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch timePickerStyle {
        case .hoursMinutes:
            switch component {
            case 0: // number of hours
                return 6
            case 2: // number of minutes
                return 60
            default: // labels "hrs" and "min"
                return 1
            }
        case .minutesSeconds:
            switch component {
            case 0: // number of minutes
                return 60
            case 2: // number of seconds
                return 60
            default: // labels "min" and "sec"
                return 1
            }

        case .minutesOnly:
            switch component {
            case 0: // number of minutes
                return 60
            default: // label "min"
                return 1
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component % 2 == 0 {
            return CGFloat(100.0)
        } else {
            return CGFloat(50.0)
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch timePickerStyle {
        case .hoursMinutes:
            switch component {
            case 1:
                return "hrs"
            case 3:
                return "min"
            default:
                return String(row)
            }
        case .minutesOnly:
            switch component {
            case 1:
                return "min"
            default:
                return String(row)
            }
        case .minutesSeconds:
            switch component {
            case 1:
                return "min"
            case 3:
                return "sec"
            default:
                return String(row)
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch timePickerStyle {
        case .minutesOnly:
            timeText = "\(row) min"
            hoursSet = 0
            minutesSet = row
            secondsSet = 0
            useBtn.isEnabled = (minutesSet > 0)
        default:
            timeText = "TBA"
            // Probably going to need refactoring to deal with multiple components
        }
        tableView.reloadData()
    }

    //MARK: - Segue to Timer Screen

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing for segue")
//        var timePickerStyle: PickerStyle = .minutesOnly
//        var hoursSet = 0
        let destinationVC = segue.destination as! SimpleTimerViewController
        destinationVC.timerName = timerName
        destinationVC.minutesSet = minutesSet
        destinationVC.secondsSet = secondsSet
        destinationVC.bucketFillColor = color.cgColor
        destinationVC.pausable = pausableSwitch?.isOn ?? false
        destinationVC.autoStart = autoStartSwitch?.isOn ?? false
        destinationVC.cancelable = cancelSwitch?.isOn ?? true

        if mode == .add && timerName == "" {
            return // Nothing to do in the database in this case.
        }
        if mode == .add {
            thisTimer = SavedTimer()
            save(thisTimer!)
        }
        guard thisTimer != nil else { return }
        if let thisTimer = thisTimer {
            do {
                try realm.write {
                    thisTimer.name = timerName
                    thisTimer.hoursSet = hoursSet
                    thisTimer.minutesSet = minutesSet
                    thisTimer.secondsSet = secondsSet
                    thisTimer.timerType = .simple
                    thisTimer.autoStart = autoStartSwitch?.isOn ?? false
                    thisTimer.pausable = pausableSwitch?.isOn ?? false
                    thisTimer.hexColor = color.hexValue()

                }
            } catch {
                print("Error writing to database: \(error)")
            }
        }
    }

    //MARK: - Database stuff

        func save(_ timer: SavedTimer) {
            print("Saving New Timer")
            do {
                try realm.write({
                    realm.add(timer, update: true)
                })
            } catch {
                print("Error saving context: \(error)")
            }
        }

    

}
