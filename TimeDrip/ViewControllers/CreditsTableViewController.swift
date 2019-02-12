//
//  CreditsTableViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/11/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit

class CreditsTableViewController: UITableViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    var credits: [[String:String]] = []
    let graphicCredits: [[String:String]] = [
        [ "name" : "Gear icon",
          "comment" : "by Reed Enger from the Noun Project",
          "link" : "https://thenounproject.com/term/gear/6067/",
        ]
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        credits.append(contentsOf: Sounds.detailedSoundArray)
        credits.append(contentsOf: graphicCredits)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("credits.count: \(credits.count)")
        return credits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "creditCell", for: indexPath) as! CreditCell
        let credit = credits[indexPath.row]


        let name = credit["name"] ?? "Unknown Resource"
        let comment = credit["comment"] ?? ""
        let link = credit["link"] ?? "unknown source"

        cell.creditTextView.text = "\(name): \(comment) from \(link)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
