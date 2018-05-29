//
//  GradientView.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 5/13/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import ChameleonFramework



typealias GradientType = (start: CGPoint, end: CGPoint)


@objc enum GradientStyle: Int {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
    case topRightBottomLeft
    case bottomLeftTopRight
    case radialCenter

    func coords() -> GradientType {
        switch self {
        case .leftRight:
            return (start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return (start: CGPoint(x: 1, y: 0.5), end: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return (start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return (start: CGPoint(x: 0.5, y: 1), end: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return (start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return (start: CGPoint(x: 1, y: 1), end: CGPoint(x: 0, y: 0))
        case .topRightBottomLeft:
            return (start: CGPoint(x: 1, y: 0), end: CGPoint(x: 0, y: 1))
        case .bottomLeftTopRight:
            return (start: CGPoint(x: 0, y: 1), end: CGPoint(x: 1, y: 0))
        case .radialCenter:
            return (start: CGPoint(x: 0.5, y: 0.5), end: CGPoint(x: 1, y: 1))
        }
    }
}


@IBDesignable
class GradientView: UIView {

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
