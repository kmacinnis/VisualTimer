//
//  SavedTimersTableViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/23/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RealmSwift

class SavedTimersTableViewController: UITableViewController {

    var timers: Results<SavedTimer>?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SavedTimerCell", bundle: nil), forCellReuseIdentifier: "savedTimerCell")
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
        return cell
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


}
