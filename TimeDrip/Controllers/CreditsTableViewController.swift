//
//  CreditsTableViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/10/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit

class CreditsListViewController: UIViewController {

    weak var coordinator: MainCoordinator?

    let sounds = Sounds.soundArray

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold) ]
        navigationItem.largeTitleDisplayMode = .automatic
    }


}

extension CreditsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let sound = sounds[indexPath.row]

        cell.textLabel?.text = sound["name"]

        return cell
    }
}
