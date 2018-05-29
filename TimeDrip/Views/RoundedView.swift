//
//  RoundedView.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 4/19/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBInspectable
    public var cornerRadius: CGFloat = 2.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            setNeedsLayout()
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
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var shadowColor: CGColor = UIColor.black.cgColor {
        didSet {
            self.layer.shadowColor = self.shadowColor
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var shadowOpacity: Float = 0.5 {
        didSet {
            self.layer.shadowOpacity = self.shadowOpacity
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var shadowOffset: CGSize = CGSize(width:2.0, height:2.0) {
        didSet {
            self.layer.shadowOffset = self.shadowOffset
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var shadowRadius: CGFloat = 3.0 {
        didSet {
            self.layer.shadowRadius = self.shadowRadius
            setNeedsLayout()
        }
    }





}
