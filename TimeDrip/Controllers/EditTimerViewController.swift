//
//  EditTimerViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/8/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RappleColorPicker

class EditTimerViewController: UITableViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    enum Mode {
        case add, edit
    }

    //TODO: Figure out how to pass in flag for add/edit mode
    var mode: Mode = .add
    var timeText: String = "Tap to set"
    var timerName: String = ""
    var color: UIColor = UIColor.blue
    var pickerVisible = false
    var pickerStyle: PickerStyle = .minutesOnly
    var hoursSet = 0
    var minutesSet = 0
    var secondsSet = 0
    var autoStart = true


    func togglePicker()  {
        pickerVisible = !pickerVisible
        tableView.reloadData()
    }

    func closePicker() {
        pickerVisible = false
        tableView.reloadData()
    }

    @objc func autoStartChanged() {
        autoStart = !autoStart
    }

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        print("Cancel Button Pressed")
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func useBtnPressed(_ sender: UIBarButtonItem) {

        performSegue(withIdentifier: "useNewTimer", sender: self)


    }



    // MARK: - View Stuff

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ColorSampleTableViewCell", bundle: nil), forCellReuseIdentifier: "colorCell")
        tableView.register(UINib(nibName: "TimePickerCell", bundle: nil), forCellReuseIdentifier: "timePickerCell")
        tableView.register(UINib(nibName: "AutoStartCell", bundle: nil), forCellReuseIdentifier: "autoStartCell")
        tableView.register(UINib(nibName: "TimeSetCell", bundle: nil), forCellReuseIdentifier: "timeSetCell")
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "titleCell")

    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
                //TODO: Attach swipe recognizer to change pickerStyle
                return cell
            case .autoStart:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! AutoStartCell
                cell.autoStartSwitch.isOn = autoStart
                cell.autoStartSwitch.addTarget(self, action: #selector(autoStartChanged), for: UIControlEvents.valueChanged)
                return cell
            case .timeSet:
                let cell = tableView.dequeueReusableCell(withIdentifier: setting.rowIdent()) as! TimeSetCell
                cell.detail.text = timeText
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
            if pickerVisible {
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
            togglePicker()
        case .timePicker:
            print("Touched timePicker")
        case .color:
            RappleColorPicker.openColorPallet { (color, num) in
                self.color = color
                RappleColorPicker.close()
                self.closePicker()
            }

        default:
            closePicker()
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
        switch pickerStyle {
        case .minutesOnly:
            return 2
        default:
            return 4
        }

    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerStyle {
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
        switch pickerStyle {
        case .minutesOnly:
            return CGFloat(50.0)
        default:
            return CGFloat(50.0)
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerStyle {
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
        switch pickerStyle {
        case .minutesOnly:
            timeText = "\(row) min"
            hoursSet = 0
            minutesSet = row
            secondsSet = 0
        default:
            timeText = "TBA"
            // Probably going to need refactoring to deal with multiple components
        }
        tableView.reloadData()
    }

    //MARK: - Segue to Timer Screen

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        let destinationVC = segue.destination as! ToDoListViewController
        //
        //        if let indexPath = tableView.indexPathForSelectedRow {
        //            destinationVC.selectedCategory = categories?[indexPath.row]
        //        }
//        var timerName: String = ""
//        var pickerStyle: PickerStyle = .minutesOnly
//        var hoursSet = 0
//        var minutesSet = 0
//        var secondsSet = 0
//        var autoStart = true
        let destinationVC = segue.destination as! SimpleTimerViewController
        destinationVC.minutesSet = minutesSet
        destinationVC.bucketFillColor = color.cgColor

        


    }
}
