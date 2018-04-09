//
//  SavedTimerCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/9/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import SwipeCellKit

class SavedTimerCell: SwipeTableViewCell {

    @IBOutlet weak var timerName: UILabel!

    @IBOutlet weak var timerIcon: UIImageView!


    override func awakeFromNib() {
        timerIcon.image = timerIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let iconLayer = timerIcon.layer
        iconLayer.shadowColor = UIColor.black.cgColor
        iconLayer.shadowOpacity = 0.4
        iconLayer.shadowOffset = CGSize(width: 1, height: 1)
        iconLayer.shadowRadius = 1
        iconLayer.shouldRasterize = true
        iconLayer.rasterizationScale = UIScreen.main.scale
    }
    
}
