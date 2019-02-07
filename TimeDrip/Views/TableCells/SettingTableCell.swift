//
//  SettingTableCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/2/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit



class SettingTableCell: UITableViewCell {
    let DIM_ALPHA = CGFloat(0.4)
    let DIM_COLOR = UIColor.flatNavyBlue
    let dimCover = UIView()


    var elements: [UIView] = []
    var expandsPicker: Bool = false

//    override func awakeFromNib() {
//        //TODO: Replace 44 with calculated cell height, to allow for adjustable text sizes.
//        dimCover.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
////        dimCover.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
//        dimCover.backgroundColor = DIM_COLOR
////        dimCover.alpha = DIM_ALPHA
//        self.addSubview(dimCover)
//        dimCover.layer.zPosition = 10
//        dimCover.isUserInteractionEnabled = true
//        dimCover.isHidden = true
//    }



    func dim(_ state: Bool) {
        dimCover.isHidden = !state
    }




}

