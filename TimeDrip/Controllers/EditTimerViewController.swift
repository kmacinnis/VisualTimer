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
import SwiftySound

//TODO:
//TODO: * change timePickerStyle by swiping picker left/right
//TODO: * tapping outside an expanded selector (style/time/sound) should close it
//TODO: * dim background when picker is visible? Maybe?
//TODO: * make work for .prefs mode
//TODO: * BUG: Cancel button on bottom bar doesn't work
//TODO: * MINOR BUG: Height of color row is off.
//TODO: * name row shouldn't show for single-use timer
//TODO: * BUG: Timer doesn't work on single-use setting


enum PickerTag: Int {
    case stylePicker
    case timePicker
    case soundPicker
    case none
}

class EditTimerViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, Storyboarded {

    weak var coordinator: MainCoordinator?

    enum Mode {
        case add, edit, singleUse, prefs
    }

    let defaults = UserDefaults.standard

    var mode: Mode = .singleUse
    var expandedPicker : PickerTag = PickerTag.none
    var timeText: String = "Tap to set"
    var soundText: String = "Tap to set"
    var styleText: String = ""
    var timerName: String = ""
    var color: UIColor = UIColor.blue
    var timePickerStyle: TimePickerStyle = .minutesOnly
    var hoursSet = 0
    var minutesSet = 0
    var secondsSet = 0
    var origAutoStart = true
    var origPausable = false
    var origCancelable = true
    var origLoopSound = true
    var allDimmedBut: Int?
    var timerStyle: TimerType = .simple

    var nameField: UITextField?
    var autoStartSwitch: UISwitch?
    var pausableSwitch: UISwitch?
    var cancelSwitch: UISwitch?
    var loopSwitch: UISwitch?
    var colorSample: UIView?
    var soundLabel: UILabel?
    var soundPicker: UIPickerView?
    var timeLabel: UILabel?
    var timePicker: UIPickerView?
    var styleLabel: UILabel?
    var stylePicker: UIPickerView?

    var thisTimer: SavedTimer?

    let realm = try! Realm()

    @objc func nameChanged() {
        timerName = (nameField?.text) ?? ""
        switch mode {
        case .edit:
            useBtn.isEnabled = (timerName != "")
        case .add:
            if timerName == "" {
                useBtn.title = "Use Timer"
            } else {
                useBtn.title = "Save & Use Timer"
            }
        default: // name field doesn't show for single-use or preferences mode
            ()
        }
    }

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        print("Cancel Button Pressed")
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func useBtnPressed(_ sender: UIBarButtonItem) {
        switch mode {
        case .add:
            saveChanges()
            coordinator?.pushSimpleTimer(timer: thisTimer!)
        case .singleUse:
            coordinator?.pushSimpleTimer(timer: thisTimer!)
        case .edit, .prefs:
            saveChanges()
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBOutlet weak var useBtn: UIBarButtonItem!

    @IBOutlet weak var bottomBar: UIToolbar!
    
    // MARK: - View Stuff

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ColorSampleTableViewCell", bundle: nil), forCellReuseIdentifier: "colorCell")
        tableView.register(UINib(nibName: "PickerCell", bundle: nil), forCellReuseIdentifier: "pickerCell")
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "toggleCell")
        tableView.register(UINib(nibName: "DisabledCell", bundle: nil), forCellReuseIdentifier: "disabledCell")

        useBtn.isEnabled = (minutesSet > 0)
        if mode == .edit {
            useBtn.title = "Save Changes"
        }
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

    fileprivate func getCorrectCell(_ indexPath: IndexPath, _ tableView: UITableView) -> SettingTableCell {
        if let setting = SettingsRow(rawValue: indexPath.row) {

            switch setting {
            case .color:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ColorSampleTableViewCell
                cell.sampleBlock.backgroundColor = color
                colorSample = cell.sampleBlock
                return cell
            case .timeSet:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! DetailCell
                cell.title.text = "Time:"
                cell.detail.text = timeText
                timeLabel = cell.detail
                return cell
            case .timePicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! PickerCell
                cell.picker.dataSource = self
                cell.picker.delegate = self
                cell.picker.tag = PickerTag.timePicker.rawValue
                timePicker = cell.picker
                if mode == .edit {
                    cell.picker.selectRow(minutesSet, inComponent: 0, animated: false)
                }
                //TODO: Attach swipe recognizer to change pickerStyle
                return cell
            case .soundSet:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! DetailCell
                cell.title.text = "Alert Sound:"
                soundLabel = cell.detail
                soundLabel?.text = soundText
                return cell
            case .soundPicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! PickerCell
                cell.picker.dataSource = self
                cell.picker.delegate = self
                cell.picker.tag = PickerTag.soundPicker.rawValue
                soundPicker = cell.picker
                if mode == .edit {
                    cell.picker.selectRow(Sounds.getIndex(filename: soundText) ?? 0, inComponent: 0, animated: false)
                }
                return cell
            case .loopAudio:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ToggleCell
                cell.toggleLabel.text = "Loop Alert Sound"
                loopSwitch = cell.toggleSwitch
                loopSwitch?.isOn = origLoopSound
                return cell
            case .styleSet:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! DetailCell
                cell.title.text = "Timer Style:"
                cell.detail.text = styleText
                styleLabel = cell.detail
                return cell
            case .stylePicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! PickerCell
                cell.picker.dataSource = self
                cell.picker.delegate = self
                cell.picker.tag = PickerTag.stylePicker.rawValue
                stylePicker = cell.picker
                if mode == .edit {
                    //TODO: Set picker to current value
                    // cell.picker.selectRow(minutesSet, inComponent: 0, animated: false)
                }
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
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! TitleCell
                nameField = cell.nameField
                nameField?.text = timerName
                nameField?.addTarget(self, action: #selector(nameChanged), for: UIControl.Event.allEditingEvents)
                if mode == .prefs || mode == .singleUse {
                    cell.isHidden = true
                }
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent(), for: indexPath) as! SettingTableCell
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "errorCell")! as! SettingTableCell
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let setting = SettingsRow(rawValue: indexPath.row) {

            if setting.disabled() {
                print(setting)
                if let cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell") {
                    return cell
                }
            }
        }
        let cell = getCorrectCell(indexPath, tableView)
        if let nonDim = allDimmedBut {
            if nonDim == indexPath.row {
                // Current focused cell
                cell.dim(false)
            } else {
                // Dimmed cell
                cell.dim(true)
            }
        } else {
            // Nothing is dimmed
            cell.dim(false)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let setting = SettingsRow(rawValue: indexPath.row)!
        if setting.disabled() {
            return 0
        }
        switch setting {
        case .timePicker:
            return (expandedPicker == .timePicker) ? 216 : 0
        case .soundPicker:
            return (expandedPicker == .soundPicker) ? 216 : 0
        case .stylePicker:
            return (expandedPicker == .stylePicker) ? 80 : 0
//        case .name:
//            if mode == .add || mode == .edit {
//                return UITableView.automaticDimension
//            } else {
//                return 0.0
//            }
        default:
//            return UITableView.automaticDimension
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsRow(rawValue: indexPath.row)! {
        case .timeSet:
            if expandedPicker != .timePicker {
                showPickerCell(timePicker!)
                allDimmedBut = indexPath.row + 1
            } else {
                hideAllPickerCells()
            }
            tableView.reloadData()
        case .styleSet:
            if expandedPicker != .stylePicker {
                showPickerCell(stylePicker!)
                allDimmedBut = indexPath.row + 1
            } else {
                hideAllPickerCells()
            }
            tableView.reloadData()
        case .soundSet:
            if expandedPicker != .soundPicker {
                allDimmedBut = indexPath.row + 1
                showPickerCell(soundPicker!)
            } else {
                hideAllPickerCells()
            }
        case .color:
            RappleColorPicker.openColorPallet { (color, _) in
                self.color = color
                RappleColorPicker.close()
                self.hideAllPickerCells()
                self.colorSample?.backgroundColor = color
            }
        default:
            hideAllPickerCells()
        }
//        tableView.beginUpdates()
//        tableView.endUpdates()
//        hideControls(allDimmedBut != nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }




    //MARK: - Picker Management

    enum TimePickerStyle {
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
        guard let tag = PickerTag(rawValue: pickerView.tag) else {
            print("Error! Picker has no tag specified!" )
            return 0
        }
        switch tag {
        case .timePicker:
            return timePickerStyle == .minutesOnly ? 2 : 4
        default:
            return 1
        }
    }

    fileprivate func numRowsInTimePickerForComponent(_ component: Int) -> Int {
        //TODO: * pull this into sep function.
        //TODO: * make this handle timePicker, soundPicker and stylePicker

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

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let tag = PickerTag(rawValue: pickerView.tag) else {return 0}
        switch tag {
        case .timePicker:
            return numRowsInTimePickerForComponent(component)
        case .soundPicker:
            return Sounds.soundArray.count
        case .stylePicker:
            return TimerType.count
        case .none:
            return 0
        }
    }

    func pickerView(_ picker: UIPickerView, widthForComponent component: Int) -> CGFloat {
        guard let tag = PickerTag(rawValue: picker.tag) else {
            print("Error! Picker has no tag specified!" )
            return 0
        }
        switch tag {
        case .timePicker:
            return component % 2 == 0 ? 100.0 : 50.0
        default:
            return picker.frame.width
        }
    }

    fileprivate func titleForRowInComponent(_ component: Int, _ row: Int) -> String? {
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

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let tag = PickerTag(rawValue: pickerView.tag) else {return ""}

        switch tag {
        case .timePicker:
            return titleForRowInComponent(component, row)
        case .stylePicker:
            return TimerType.all[row]
        case .soundPicker:
            return Sounds.soundArray[row]["name"] ?? "???"
        case .none:
            return ""
        }
    }

    fileprivate func didSelectRowInTimePicker(_ row: Int) {
        switch timePickerStyle {
        case .minutesOnly:
            timeText = "\(row) min"
            timeLabel?.text = timeText
            hoursSet = 0
            minutesSet = row
            secondsSet = 0
            useBtn.isEnabled = (minutesSet > 0)
        default:
            timeText = "TBA"
            // Probably going to need refactoring to deal with multiple components
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let tag = PickerTag(rawValue: pickerView.tag) else {return}

        switch tag {
        case .timePicker:
            didSelectRowInTimePicker(row)
        case .soundPicker:
            soundText = Sounds.soundArray[row]["file"] ?? ""
            soundLabel?.text = Sounds.soundArray[row]["name"] ?? "???"
            let soundFile = "sounds/\(soundText)"
            Sound.stopAll()
            Sound.play(file: soundFile, fileExtension: "wav")
        case .stylePicker:
            styleText = TimerType.all[row]
            timerStyle = TimerType(rawValue: row)!
        case .none:
            ()
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    //MARK:- PickerView Animations

    func showPickerCell(_ picker:UIPickerView) {
        guard let tag = PickerTag(rawValue: picker.tag) else {
            print("Error! Picker has no tag specified!" )
            return
        }

        expandedPicker = tag
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.isHidden = false
        picker.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            picker.alpha = 1.0
        }, completion: {(finished) -> Void in
            picker.isHidden = false

        }
        )
    }

    func hidePickerCell(_ picker:UIPickerView) {
        guard let tag = PickerTag(rawValue: picker.tag) else {
            print("Error! Picker has no tag specified!" )
            return
        }

        if tag == .soundPicker {
            Sound.stopAll()
        }
        expandedPicker = PickerTag.none
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            picker.alpha = 0.0
        }, completion: {(finished) -> Void in
            picker.isHidden = true

        }
        )

    }

    func hideAllPickerCells() {
        for picker in [soundPicker,timePicker,stylePicker].compactMap({ $0 }) {
            hidePickerCell(picker)
        }
        allDimmedBut = nil
    }

    //MARK: - Database stuff

    func saveChanges() {
        if mode == .prefs {
            defaults.set(pausableSwitch?.isOn ?? false, forKey: "pausable")
            defaults.set(autoStartSwitch?.isOn ?? false, forKey: "autoStart")
            defaults.set(cancelSwitch?.isOn ?? true, forKey: "cancelable")
            defaults.set(color.hexValue(), forKey: "color")
            defaults.set(timerStyle.rawValue, forKey: "style")
            defaults.set(soundText, forKey: "alertSound")
            defaults.set(loopSwitch?.isOn ?? true, forKey: "loopAudio")
            return
        }
        if mode == .add {
            thisTimer = SavedTimer()
            do {
                try realm.write({
                    realm.add(thisTimer!, update: true)
                })
            } catch {
                print("Error saving new timer: \(error)")
            }
        }
        if let thisTimer = thisTimer {
            do {
                try realm.write {
                    thisTimer.name = timerName
                    thisTimer.hoursSet = hoursSet
                    thisTimer.minutesSet = minutesSet
                    thisTimer.secondsSet = secondsSet
                    thisTimer.timerType = timerStyle
                    thisTimer.autoStart = autoStartSwitch?.isOn ?? false
                    thisTimer.pausable = pausableSwitch?.isOn ?? false
                    thisTimer.hexColor = color.hexValue()
                    thisTimer.cancelable = cancelSwitch?.isOn ?? true
                    thisTimer.loopAudio = loopSwitch?.isOn ?? true
                    thisTimer.sound = soundText
                }
            } catch {
                print("Error writing to database: \(error)")
            }
        } else {
            print("Error: unexpected nil timer in \(mode) mode.")
        }
    }



    

}
