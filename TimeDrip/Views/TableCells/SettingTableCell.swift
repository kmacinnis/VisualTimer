//
//  KMTableCell.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/2/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit



protocol ListedElements {
    var elements: [UIView] { get set }
}

class SettingTableCell: UITableViewCell, ListedElements {

    var elements: [UIView] = []
    var expandsPicker: Bool = false




}


//extension UIView {
//    var textColor: UIColor {
//        return UIColor.black
//    }
//}
