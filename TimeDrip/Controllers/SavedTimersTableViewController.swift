//
//  SavedTimersTableViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/23/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit



class SavedTimersTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var timers: Results<SavedTimer>?
    let realm = try! Realm()
    var timerForEditing: SavedTimer?

    @objc func addTimer() {
        performSegue(withIdentifier: "newTimer", sender: self)
    }

    @objc func orderingModeOn() {
        tableView.isEditing = true
        let doneBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(orderingModeOff))
        navigationItem.setRightBarButtonItems([doneBarBtn], animated: true)
        tableView.reloadData()
    }

    @objc func orderingModeOff() {
        tableView.isEditing = false

        let editBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(SavedTimersTableViewController.orderingModeOn))
        let addBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(SavedTimersTableViewController.addTimer))

        self.navigationItem.setRightBarButtonItems([addBarBtn, editBarBtn], animated: true)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SavedTimerCell", bundle: nil), forCellReuseIdentifier: "savedTimerCell")

        let editBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(SavedTimersTableViewController.orderingModeOn))
        let addBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(SavedTimersTableViewController.addTimer))
//        let infoBarBtn = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(SavedTimersTableViewController.showInfo))
        self.navigationItem.rightBarButtonItems = [addBarBtn, editBarBtn]
    }

    override func viewWillAppear(_ animated: Bool) {
        loadSavedTimers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startTimer" {
            let destinationVC = segue.destination as! SimpleTimerViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                if let timer = timers?[indexPath.row] {
                    destinationVC.minutesSet = timer.minutesSet
                    destinationVC.secondsSet = timer.secondsSet
                    destinationVC.bucketFillColor = UIColor.init(hexString: timer.hexColor)?.cgColor ?? UIColor.gray.cgColor
                    destinationVC.pausable = timer.pausable
                    destinationVC.autoStart = timer.autoStart
                }
            }
        } else if segue.identifier == "editTimer" {
            let destinationVC = segue.destination as! EditTimerViewController
            if let timer = timerForEditing {
                print("timer: \(timer)")
                destinationVC.mode = .edit
                destinationVC.thisTimer = timer
                destinationVC.minutesSet = timer.minutesSet
                destinationVC.secondsSet = timer.secondsSet
                destinationVC.color = UIColor.init(hexString: timer.hexColor) ?? UIColor.gray
                destinationVC.origPausable = timer.pausable
                destinationVC.origAutoStart = timer.autoStart
                destinationVC.timeText = "\(timer.minutesSet) min"
                destinationVC.timerName = timer.name
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }


    //MARK: - TableView DataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "savedTimerCell", for: indexPath) as! SavedTimerCell
        cell.timerName?.text = timers?[indexPath.row].name ?? "No Timers Found. Tap + to create new timer."
        if let iconColor = UIColor.init(hexString: (timers?[indexPath.row].hexColor)!) {
            cell.timerIcon.tintColor = iconColor
        }
        cell.delegate = self
        return cell
    }

        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            do {
                let start = sourceIndexPath.row
                let end = destinationIndexPath.row

                let movedTimer = (timers?[start])!
                try realm.write {
                    if start < end {
                        for i in (start + 1)...end {
                            timers?[i].sortOrder = i - 1
                        }
                    } else if end < start {
                        for i in stride(from: start - 1, through: end, by: -1) {
                            timers?[i].sortOrder = i + 1
                        }
                    }
                    movedTimer.sortOrder = end
                }
            } catch {
                print("Error saving change in order to database: \(error)")
            }
        }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "startTimer", sender: self)
    }


    //MARK: - Database stuff

    func loadSavedTimers() {
        let sortProperties = [SortDescriptor(keyPath: "sortOrder", ascending: true), SortDescriptor(keyPath: "dateCreated", ascending: true)]
        timers = realm.objects(SavedTimer.self).sorted(by: sortProperties)

        tableView.reloadData()
    }

    func deleteTimer(at indexPath: IndexPath) {
        if let timer = self.timers?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(timer)
                }
            } catch {
                print("Error deleting timer: \(error)")
            }
        }
    }

    func updateOrder() {
        do {
            try realm.write {
                for i in 0...((timers?.count)! - 1) {
                    timers?[i].sortOrder = i
                }
            }
        } catch {
            print("Error saving order to database: \(error)")
        }
    }


    //MARK: - Swipe For Editing/Deleting

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("delete \(indexPath)")
            self.deleteTimer(at: indexPath)
        }

        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            print("edit \(indexPath)")
            self.timerForEditing = self.timers?[indexPath.row]
            self.performSegue(withIdentifier: "editTimer", sender: self)
        }
        editAction.backgroundColor = UIColor.init(hexString: "#FFAE00")

        let dragAction = SwipeAction(style: .default, title: "Drag") { (action, indexPath) in

        }
        dragAction.backgroundColor = UIColor.flatSkyBlue
        switch orientation {
        case .right:
            return [deleteAction, editAction]
        case .left:
            return [dragAction]
        }
    }

        func tableView(_ tableView: UITableView,                            editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
            var options = SwipeTableOptions()
            options.transitionStyle = .border
            return options
        }

}

