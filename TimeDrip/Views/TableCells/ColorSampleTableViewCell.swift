//
//  ColorSampleTableViewCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/4/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class ColorSampleTableViewCell: SettingTableCell {

    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var sampleBlock: UIView!

    func elementsx() -> [UIView] {
        return [colorLabel, sampleBlock]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        elements =  [colorLabel, sampleBlock]
    }

}
