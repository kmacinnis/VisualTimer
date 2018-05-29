//
//  RoundedGradientView.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 5/13/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class RoundedGradientView: RoundedView {

    private let gradient : CAGradientLayer = CAGradientLayer()

    @IBInspectable
    public var startColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var endColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable
    public var gradientStyle: GradientStyle = GradientStyle.topBottom {
        didSet {
            setNeedsLayout()
        }
    }


    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradient.frame = self.bounds
    }

    override public func draw(_ rect: CGRect) {
        self.gradient.frame = self.bounds
        self.gradient.colors = [startColor.cgColor, endColor.cgColor]
        self.gradient.startPoint = self.gradientStyle.coords().start
        self.gradient.endPoint = self.gradientStyle.coords().end
        if self.gradient.superlayer == nil {
            self.layer.insertSublayer(self.gradient, at: 0)
        }
    }

}
