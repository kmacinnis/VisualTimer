//
//  TitleCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/8/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class TitleCell: SettingTableCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func nameFieldChanged(_ sender: Any) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        elements = [nameLabel, nameField]
    }
}
