//
//  RoundedButton.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 3/24/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundedButton: UIButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setTitle("Cancel", for: .normal)
        setTitleColor(UIColor.flatRed, for: .normal)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBInspectable
    public var cornerRadius: CGFloat = 2.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }

    @IBInspectable
    public var showShadow: Bool = false {
        didSet {
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            self.layer.shadowColor = self.shadowColor
            self.layer.shadowOpacity = self.shadowOpacity
            self.layer.shadowOffset = self.shadowOffset
            self.layer.shadowRadius = self.shadowRadius


        }
    }

    @IBInspectable
    public var shadowColor: CGColor = UIColor.black.cgColor {
        didSet {
            self.layer.shadowColor = self.shadowColor
        }
    }

    @IBInspectable
    public var shadowOpacity: Float = 0.5 {
        didSet {
            self.layer.shadowOpacity = self.shadowOpacity
        }
    }

    @IBInspectable
    public var shadowOffset: CGSize = CGSize(width:2.0, height:2.0) {
        didSet {
            self.layer.shadowOffset = self.shadowOffset
        }
    }

    @IBInspectable
    public var shadowRadius: CGFloat = 3.0 {
        didSet {
            self.layer.shadowRadius = self.shadowRadius
        }
    }



}
