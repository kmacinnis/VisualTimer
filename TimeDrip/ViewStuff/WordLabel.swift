//
//  ViewStuff.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/19/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

func wordLabel(_ myText: String?) -> UILabel {
    let label = UILabel()
    label.text = myText
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 24)
    label.adjustsFontSizeToFitWidth = true
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.flatBlackDark
    label.backgroundColor = UIColor.clear

    return label
}

