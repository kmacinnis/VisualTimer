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
// * change timePickerStyle by swiping picker left/right
// * "Save Changes" in .edit mode shouldn't go back to root
// * need to reload tableview after changes in color/sound/time
// * tapping outside an expanded selector (style/time/sound) should close it
// * make work for .prefs mode


enum PickerTag: Int {
    case stylePicker
    case timePicker
    case soundPicker
}

class EditTimerViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, Storyboarded {

    weak var coordinator: MainCoordinator?

    enum Mode {
        case add, edit, singleUse, prefs
    }

    let defaults = UserDefaults.standard

    var mode: Mode = .add
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
    var stylePickerHidden: Bool = true
    var timePickerHidden: Bool = true
    var soundPickerHidden: Bool = true
    var timerStyle: TimerType = .simple

    var nameField: UITextField?
    var autoStartSwitch: UISwitch?
    var pausableSwitch: UISwitch?
    var cancelSwitch: UISwitch?
    var loopSwitch: UISwitch?
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
//            performSegue(withIdentifier: "useNewTimer", sender: self)
            coordinator?.pushSimpleTimer(timer: thisTimer!)
        case .edit, .prefs:
            saveChanges()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    @IBOutlet weak var useBtn: UIBarButtonItem!


    // MARK: - View Stuff

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ColorSampleTableViewCell", bundle: nil), forCellReuseIdentifier: "colorCell")
        tableView.register(UINib(nibName: "PickerCell", bundle: nil), forCellReuseIdentifier: "pickerCell")
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "ToggleCell", bundle: nil), forCellReuseIdentifier: "toggleCell")

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let setting = SettingsRow(rawValue: indexPath.row) {
            switch setting {
            case .color:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent()) as! ColorSampleTableViewCell
                cell.sampleBlock.backgroundColor = color
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
                nameField?.addTarget(self, action: #selector(nameChanged), for: UIControlEvents.allEditingEvents)
                if mode == .prefs || mode == .singleUse {
                    cell.isHidden = true
                }
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: setting.reuseIdent(), for: indexPath)
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "errorCell")!
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch SettingsRow(rawValue: indexPath.row)! {
        case .timePicker:
            return timePickerHidden ? 0 : 216
        case .soundPicker:
            return soundPickerHidden ? 0 : 216
        case .stylePicker:
            return stylePickerHidden ? 0 : 80
        case .name:
            if mode == .add || mode == .edit {
                return UITableViewAutomaticDimension
            } else {
                return 0.0
            }
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsRow(rawValue: indexPath.row)! {
        case .timeSet:
            if timePickerHidden {
                showPickerCell(timePicker!)
            } else {
                hidePickerCell(timePicker!)
            }
        case .styleSet:
            if stylePickerHidden {
                showPickerCell(stylePicker!)
            } else {
                hidePickerCell(stylePicker!)
            }
        case .soundSet:
            if soundPickerHidden {
                showPickerCell(soundPicker!)
            } else {
                hidePickerCell(soundPicker!)
            }
        case .color:
            RappleColorPicker.openColorPallet { (color, _) in
                self.color = color
                RappleColorPicker.close()
                self.hideAllPickerCells()
            }
        case .timePicker, .soundPicker:
            print("Touched picker")
        default:
            hideAllPickerCells()
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        //      * make this handle timePicker, soundPicker and stylePicker

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
        }
    }

    fileprivate func didSelectRowInTimePicker(_ row: Int) {
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
        var detailLabel: UILabel!

        switch tag {
        case .soundPicker:
            soundPickerHidden = false
            detailLabel = soundLabel
        case .timePicker:
            timePickerHidden = false
            detailLabel = timeLabel
        case .stylePicker:
            stylePickerHidden = false
            detailLabel = styleLabel
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.isHidden = false
        picker.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            picker.alpha = 1.0
            picker.tintColor = UIColor.red
            detailLabel.textColor = UIColor.orange
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
        var detailLabel: UILabel!

        switch tag {
        case .soundPicker:
            soundPickerHidden = true
            detailLabel = soundLabel
            Sound.stopAll()
        case .timePicker:
            timePickerHidden = true
            detailLabel = timeLabel
        case .stylePicker:
            stylePickerHidden = true
            detailLabel = styleLabel
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            picker.alpha = 0.0
            detailLabel.textColor = UIColor.darkText
        }, completion: {(finished) -> Void in
            picker.isHidden = true

        }
        )

    }

    func hideAllPickerCells() {
        for picker in [soundPicker,].compactMap({ $0 }) {
            hidePickerCell(picker)
        }
    }





    //MARK: - Segue to Timer Screen

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationVC = segue.destination as! SimpleTimerViewController
        destinationVC.timerName = timerName
        destinationVC.minutesSet = minutesSet
        destinationVC.secondsSet = secondsSet
        destinationVC.bucketFillColor = color.cgColor
        destinationVC.pausable = pausableSwitch?.isOn ?? false
        destinationVC.autoStart = autoStartSwitch?.isOn ?? false
        destinationVC.cancelable = cancelSwitch?.isOn ?? true
        destinationVC.alertSound = soundText
        destinationVC.loopAudio = loopSwitch?.isOn ?? true
        //TODO:- Change above ??s to read from defaults


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
