//
//  KMTableCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/2/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit



class SettingTableCell: UITableViewCell {
    let DIM_ALPHA = CGFloat(0.1)
    let DIM_COLOR = UIColor.flatGray


    var elements: [UIView] = []
    var expandsPicker: Bool = false

    func dimElements(dim: Bool) {
        backgroundColor = dim ? DIM_COLOR : UIColor.white
        for element in elements {
            element.alpha = dim ? DIM_ALPHA : CGFloat(1.0)
        }
    }


}

