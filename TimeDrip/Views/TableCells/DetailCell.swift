//
//  DetailCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/8/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class DetailCell: SettingTableCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        elements = [title, detail]
        expandsPicker = true
    }
}
