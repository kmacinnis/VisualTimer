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


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - TableView DataSource Methods


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTimerArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTimerCell", for: indexPath)
//        cell.textLabel?.text = savedTimerArray[indexPath.row]

        return cell
    }

    //MARK: - Add New Timer


    @IBAction func addButtonPressed(_ sender: Any) {

    }





    //MARK: - Fake data examples

    //class SavedTimer: Object {
    //    @objc dynamic var title: String = ""
    //    @objc dynamic var minutesSet: Int = 5
    //    @objc dynamic var hexColor: String = ""
    //    @objc dynamic var dateCreated: Date = Date()
    //    @objc dynamic var sortOrder: Int = 99
    //}

    let savedTimerArray = [
        ["title": "Two Minute Timer",
         "minutesSet": 2,
         "hexColor": "",
         "sortOrder": 1
         ],
        ["title": "Five Minute Timer",
         "minutesSet": 5,
         "hexColor": "",
         "sortOrder":2
        ]

    ]

}
