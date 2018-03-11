//
//  SavedTimerCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/9/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class SavedTimerCell: UITableViewCell {

    @IBOutlet weak var timerName: UILabel!

    @IBOutlet weak var timerIcon: UIImageView!


    override func awakeFromNib() {
        timerIcon.image = timerIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
    
}
