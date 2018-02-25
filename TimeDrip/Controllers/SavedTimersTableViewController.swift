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

    let savedTimerArray = ["Three-minute timer", "Tomato timer", "Silly nonsense" ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - TableView DataSource Methods


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTimerArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTimerCell", for: indexPath)
        cell.textLabel?.text = savedTimerArray[indexPath.row]

        return cell
    }

    //MARK: - Add New Timer


    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(nibName: <#T##String?#>, bundle: <#T##Bundle?#>)

    }


}
