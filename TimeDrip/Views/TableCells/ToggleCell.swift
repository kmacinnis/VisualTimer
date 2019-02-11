//
//  ToggleCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/9/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class ToggleCell: SettingTableCell {

    @IBOutlet weak var toggleLabel: UILabel!

    @IBOutlet weak var toggleSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        elements = [toggleLabel, toggleSwitch]
    }
}
