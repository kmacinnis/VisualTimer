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

//TODO:
// * make cells reorderable


class SavedTimersTableViewController: UITableViewController, SwipeTableViewCellDelegate {


    var timers: Results<SavedTimer>?
    let realm = try! Realm()
    var timerForEditing: SavedTimer?


    @IBAction func reorderPressed(_ sender: Any) {
        tableView.isEditing = true
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SavedTimerCell", bundle: nil), forCellReuseIdentifier: "savedTimerCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        loadSavedTimers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prpepare for segue: \(String(describing: segue.identifier))")
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

        if tableView.isEditing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderableCell", for: indexPath)
            cell.textLabel?.text = timers?[indexPath.row].name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedTimerCell", for: indexPath) as! SavedTimerCell
            cell.timerName?.text = timers?[indexPath.row].name ?? "No Timers Found. Tap + to create new timer."
            if let iconColor = UIColor.init(hexString: (timers?[indexPath.row].hexColor)!) {
                cell.timerIcon.tintColor = iconColor
            }
            cell.delegate = self
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
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


    @IBAction func addButtonPressed(_ sender: Any) {

    }

    //MARK: - Database stuff

    func loadSavedTimers() {
        timers = realm.objects(SavedTimer.self)
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
