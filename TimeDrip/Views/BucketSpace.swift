//
//  BucketSpace.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 6/1/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit

class BucketSpace: UIView {

    //MARK: - Initialize stuff
    var parentVC: SimpleTimerViewController!

    let bucketView = UIView()
    let bucketFillLayer = CAShapeLayer()
    let bucketMeasureView = UIView()
    var labelList: [UILabel] = []
    let replicatorLayer = CAReplicatorLayer()
    let instanceLayer = CALayer()

    var bucketLineColor: UIColor {
        return parentVC.bucketLineColor
    }
    var fillColor : CGColor {
        return parentVC.bucketFillColor
    }

    var totalMinutes: Int {
        return parentVC.minutesSet
    }

    var ready: Bool = false



    //MARK: - Draw stuff

    func setUpMeasureMarks() {
        let layerWidth = CGFloat(bucketView.frame.width)
        instanceLayer.frame = CGRect(x: bucketView.bounds.minX, y: 0.0, width: layerWidth, height: 2)
        instanceLayer.backgroundColor = bucketLineColor.cgColor
    }

    func setUpReplicatorLayer(size: CGSize) {
        replicatorLayer.frame = bucketView.bounds
        replicatorLayer.instanceCount = Int(totalMinutes)
        replicatorLayer.preservesDepth = false
        let vertShift = size.height / CGFloat(totalMinutes)
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0.0, vertShift, 0.0)
    }

    func setUpMeasureLabels() {
        var label : UILabel
        labelList = []
        for _ in 1...totalMinutes {
            labelList.append(UILabel())
        }
        for i in 1...totalMinutes {
            label = labelList[i-1]
            label.text = "\(i)"
            label.tintColor = bucketLineColor
            label.font = UIFont.systemFont(ofSize: 14)
            bucketMeasureView.addSubview(label)
        }
        positionMeasureLabels()
    }

    func positionMeasureLabels() {
        let vertShift = bucketView.frame.height / CGFloat(totalMinutes)
        let minX = bucketMeasureView.bounds.minX + 3
        let width = bucketMeasureView.bounds.width
        let bottom = bucketMeasureView.bounds.height
        var currentY = CGFloat(0.0)
        var label : UILabel

        for i in 1...totalMinutes {
            label = labelList[i-1]
            currentY = bottom - CGFloat(i) * vertShift - 10
            label.frame = CGRect(x: minX, y: currentY, width: width, height: 21)
        }

    }

    func setUpBucketFill() {
        bucketView.layer.addSublayer(bucketFillLayer)
        bucketFillLayer.fillColor = fillColor
        bucketFillLayer.frame = bucketView.bounds
        if parentVC.timerInUse {
            bucketFillLayer.path = bucketFillPath().cgPath
        } else {
            bucketFillLayer.path = bucketFillPath(0.0).cgPath
        }
    }

    func bucketFillPath(_ pd: Float? = nil) -> UIBezierPath {
        let percentDrained = pd ?? 1.0 - parentVC.percentRun()
        let minX = bucketView.bounds.minX
        let maxX = bucketView.bounds.maxX
        let maxY = bucketView.bounds.maxY
        let minY = CGFloat(percentDrained) * maxY

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: minX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: maxY))
        fillPath.addLine(to: CGPoint(x: minX, y: maxY))
        fillPath.close()

        return fillPath
    }

    func drawBucketOutline() {
        self.backgroundColor = UIColor.clear
        self.addSubview(bucketView)
        bucketView.backgroundColor = UIColor.clear
        let horizPadding = CGFloat(25)
        let vertPadding = CGFloat(20)

        bucketView.layer.borderWidth = 2
        bucketView.layer.borderColor = bucketLineColor.cgColor
        //        bucketView.tintColor
        bucketView.translatesAutoresizingMaskIntoConstraints = false
        let bucketLeft = NSLayoutConstraint(item: bucketView, attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self, attribute: .leftMargin,
                                            multiplier: 1.0, constant: horizPadding)
        let bucketRight = NSLayoutConstraint(item: bucketView, attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self, attribute: .rightMargin,
                                             multiplier: 1.0, constant: -horizPadding)
        let bucketTop = NSLayoutConstraint(item: bucketView, attribute: .top,
                                           relatedBy: .equal,
                                           toItem: self, attribute: .top,
                                           multiplier: 1.0, constant: vertPadding)
        let bucketBottom = NSLayoutConstraint(item: bucketView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self, attribute: .bottom,
                                              multiplier: 1.0, constant: -3*vertPadding)
        NSLayoutConstraint.activate([bucketTop, bucketBottom, bucketLeft, bucketRight])

        self.addSubview(bucketMeasureView)
        bucketMeasureView.translatesAutoresizingMaskIntoConstraints = false
        bucketMeasureView.backgroundColor = UIColor.clear
        let labelLeft = NSLayoutConstraint(item: bucketMeasureView, attribute: .left,
                                           relatedBy: .equal,
                                           toItem: bucketView, attribute: .right,
                                           multiplier: 1.0, constant: 0.0)
        let labelRight = NSLayoutConstraint(item: bucketMeasureView, attribute: .right,
                                            relatedBy: .equal,
                                            toItem: self, attribute: .rightMargin,
                                            multiplier: 1.0, constant: 0.0)
        let labelTop = NSLayoutConstraint(item: bucketMeasureView, attribute: .top,
                                          relatedBy: .equal,
                                          toItem: bucketView, attribute: .top,
                                          multiplier: 1.0, constant: 0.0)
        let labelBottom = NSLayoutConstraint(item: bucketMeasureView, attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: bucketView, attribute: .bottom,
                                             multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([labelTop,labelLeft,labelRight,labelBottom])

        ready = true

    }

    func updateFillPath() {
        bucketFillLayer.path = bucketFillPath().cgPath
    }

    func stopAnimations() {
        bucketFillLayer.removeAllAnimations()
    }

    func bucketFillExample()  {
        let minX = bucketView.bounds.minX
        let maxX = bucketView.bounds.maxX
        // Must swap min and max Y for proper draining
        let minY = bucketView.bounds.maxY
        let maxY = minY + 200

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: minX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: maxY))
        fillPath.addLine(to: CGPoint(x: minX, y: maxY))
        fillPath.close()

        bucketFillLayer.frame = bucketView.frame
        bucketFillLayer.path = fillPath.cgPath
    }

    func adjustBucketInsides() {
        print("Setting up insides")
        print(bucketView.frame.size)
        setUpReplicatorLayer(size: bucketView.frame.size)
        bucketView.layer.addSublayer(replicatorLayer)
        setUpMeasureMarks()
        replicatorLayer.addSublayer(instanceLayer)
        positionMeasureLabels()

    }

    func setUpBucket() {
        drawBucketOutline()
        setUpMeasureLabels()
        setUpBucketFill()
        setNeedsLayout()
        layoutIfNeeded()
        adjustBucketInsides()
    }

    func drainBucket() {
        bucketFillLayer.removeAllAnimations()
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.fromValue = bucketFillPath().cgPath
        basicAnimation.toValue = bucketFillPath(1.0).cgPath
        let duration = parentVC.minutes * 60 + parentVC.seconds
        basicAnimation.duration = CFTimeInterval(duration)
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        bucketFillLayer.add(basicAnimation, forKey: "drain")
    }
    

}
