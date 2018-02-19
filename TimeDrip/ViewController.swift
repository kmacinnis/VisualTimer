//
//  ViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/13/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import CoreGraphics
import ChameleonFramework

class ViewController: UIViewController {

    //MARK: - Initialize stuff
//    let bucketLayer = CAShapeLayer()
    let bucketView = UIView()
    let bucketFillLayer = CAShapeLayer()
    let bucketLabelView = UIView()
    var labelList: [UILabel] = []
    let replicatorLayer = CAReplicatorLayer()
    let instanceLayer = CALayer()


    let bucketLineColor = UIColor.flatBlackDark.cgColor
    let bucketFillColor = UIColor.flatMint.cgColor

    let minuteLabel: UILabel = {
        let label = timeLabel("M")
        return label
    }()

    let secondLabel: UILabel = {
        let label = timeLabel("S")
        return label
    }()

    let wordLabelMinutes: UILabel = {
        let label = wordLabel("Minutes")
        return label
    }()

    let wordLabelSeconds: UILabel = {
        let label = wordLabel("Seconds")
        return label
    }()

    var minutesSet: Int = 3
    var minutes: Int = 1
    var seconds: Int = 0
    
    var timer = Timer()
    var timerInUse: Bool = false
    var timerPaused: Bool = false

    @IBOutlet weak var timerButton: UIButton!

    //MARK: - Timer functionality

    func runTimer() {
        if !timerInUse{
            minutes = minutesSet
            seconds = 0
        }
        timerInUse = true
        timerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        drainBucket()
        timerButton.setTitle("Pause", for: .normal)
    }

    func pauseTimer() {
        timer.invalidate()
        bucketFillLayer.removeAnimation(forKey: "drain")
        timerButton.setTitle("Resume", for: .normal)
        timerPaused = true
    }


    @objc func updateTimer() {
        if seconds == 0 {
            minutes -= 1
            seconds = 59
        } else {
            seconds -= 1
        }
        minuteLabel.text = "\(minutes)"
        secondLabel.text = "\(seconds)"
        
    }
    
    
    @IBAction func timerButtonPressed(_ sender: Any) {
        // timerPaused or not timerInUse
        if timerPaused || !timerInUse {
            runTimer()
        } else {
            pauseTimer()
        }

    }

    //MARK: - Draw stuff

    func setUpInstanceLayer() {
        let layerWidth = CGFloat(bucketView.frame.width)
        instanceLayer.frame = CGRect(x: bucketView.bounds.minX, y: 0.0, width: layerWidth, height: 2)
        instanceLayer.backgroundColor = bucketLineColor
    }

    func setUpReplicatorLayer() {
        replicatorLayer.frame = bucketView.bounds
        replicatorLayer.instanceCount = Int(minutesSet)
        replicatorLayer.preservesDepth = false
        let vertShift = bucketView.frame.height / CGFloat(minutesSet)
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0.0, vertShift, 0.0)
    }
    
    func setUpMeasureLabels() {
        var label : UILabel
        labelList = []
        for _ in 1...minutesSet {
            labelList.append(UILabel())
        }
        for i in 1...minutesSet {
            label = labelList[i-1]
            label.text = "\(i)"
            label.textColor = UIColor(cgColor: bucketLineColor)
            label.font = UIFont.systemFont(ofSize: 14)
            bucketLabelView.addSubview(label)
                }
        positionMeasureLabels()
        }

    func positionMeasureLabels() {
        let vertShift = bucketView.frame.height / CGFloat(minutesSet)
        let minX = bucketLabelView.bounds.minX + 3
        let width = bucketLabelView.bounds.width
        let bottom = bucketLabelView.bounds.height
        var currentY = CGFloat(0.0)
        var label : UILabel

        for i in 1...minutesSet {
            label = labelList[i-1]
            currentY = bottom - CGFloat(i) * vertShift - 10
            label.frame = CGRect(x: minX, y: currentY, width: width, height: 21)
        }

    }

    func fillBucket() {
        bucketView.layer.addSublayer(bucketFillLayer)
        bucketFillLayer.fillColor = bucketFillColor
        bucketFillLayer.frame = bucketView.bounds
        if timerInUse {
            bucketFillLayer.path = bucketFillPath().cgPath
        } else {
            bucketFillLayer.path = bucketFillPath(1.0).cgPath
        }
    }

    func bucketFillPath(_ pd: Float? = nil) -> UIBezierPath {
        let percentDrained = pd ?? Float(minutes * 60 + seconds)/Float(minutesSet * 60)
        let minX = bucketView.bounds.minX
        let maxX = bucketView.bounds.maxX
        // Must swap min and max Y for proper draining
        let minY = bucketView.bounds.maxY
        let maxY = bucketView.bounds.minY * CGFloat(percentDrained)

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: minX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: minY))
        fillPath.addLine(to: CGPoint(x: maxX, y: maxY))
        fillPath.addLine(to: CGPoint(x: minX, y: maxY))
        fillPath.close()

        return fillPath
    }


    func drainBucket() {
        let startPath = bucketFillPath()
        print("startPath: ",startPath)
        let endPath = bucketFillPath(0.0)
        print("endPath: ", endPath)



        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.fromValue = bucketFillPath().cgPath
        basicAnimation.toValue = bucketFillPath(0.0).cgPath
        basicAnimation.duration = CFTimeInterval(minutes * 60 + seconds)
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        bucketFillLayer.add(basicAnimation, forKey: "drain")
    }



    func drawBucketOutline() {
        view.addSubview(bucketView)
        bucketView.backgroundColor = UIColor.clear
        let padding = CGFloat(10.0)

        bucketView.layer.borderWidth = 2
        bucketView.layer.borderColor = bucketLineColor
        bucketView.translatesAutoresizingMaskIntoConstraints = false
        let bucketLeft = NSLayoutConstraint(item: bucketView, attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self.view, attribute: .leftMargin,
                                            multiplier: 1.0, constant: padding)
        let bucketRight = NSLayoutConstraint(item: bucketView, attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self.view, attribute: .centerXWithinMargins,
                                             multiplier: 1.0, constant: -padding)
        let bucketTop = NSLayoutConstraint(item: bucketView, attribute: .top,
                                           relatedBy: .equal,
                                           toItem: self.view, attribute: .topMargin,
                                           multiplier: 1.0, constant: 20.0)
        let bucketBottom = NSLayoutConstraint(item: bucketView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.view, attribute: .bottomMargin,
                                              multiplier: 1.0, constant: -50)
        NSLayoutConstraint.activate([bucketTop, bucketBottom, bucketLeft, bucketRight])

        view.addSubview(bucketLabelView)
        bucketLabelView.translatesAutoresizingMaskIntoConstraints = false
        bucketLabelView.backgroundColor = UIColor.clear
        let labelLeft = NSLayoutConstraint(item: bucketLabelView, attribute: .left,
                                           relatedBy: .equal,
                                           toItem: bucketView, attribute: .right,
                                           multiplier: 1.0, constant: 0.0)
        let labelRight = NSLayoutConstraint(item: bucketLabelView, attribute: .right,
                                            relatedBy: .equal,
                                            toItem: self.view, attribute: .centerX,
                                            multiplier: 1.0, constant: padding)
        let labelTop = NSLayoutConstraint(item: bucketLabelView, attribute: .top,
                                          relatedBy: .equal,
                                          toItem: bucketView, attribute: .top,
                                          multiplier: 1.0, constant: 0.0)
        let labelBottom = NSLayoutConstraint(item: bucketLabelView, attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: bucketView, attribute: .bottom,
                                             multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([labelTop,labelLeft,labelRight,labelBottom])

    }

    func setUpTimeView() {
        let timeView = UIView()
        view.addSubview(timeView)
        let spacer = CGFloat(30.0)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.backgroundColor = UIColor.clear
        let labelLeft = NSLayoutConstraint(item: timeView, attribute: .left,
                                           relatedBy: .equal,
                                           toItem: bucketLabelView, attribute: .right,
                                           multiplier: 1.0, constant: 0.0)
        let labelRight = NSLayoutConstraint(item: timeView, attribute: .right,
                                            relatedBy: .equal,
                                            toItem: self.view, attribute: .rightMargin,
                                            multiplier: 1.0, constant: 0.0)
        let labelTop = NSLayoutConstraint(item: timeView, attribute: .top,
                                          relatedBy: .equal,
                                          toItem: bucketView, attribute: .top,
                                          multiplier: 1.0, constant: 0.0)
        let labelBottom = NSLayoutConstraint(item: timeView, attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: bucketView, attribute: .bottom,
                                             multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([labelTop,labelLeft,labelRight,labelBottom])
        timeView.addSubview(minuteLabel)
        timeView.addSubview(secondLabel)
        timeView.addSubview(wordLabelMinutes)
        timeView.addSubview(wordLabelSeconds)

        // Center labels horizontally
        NSLayoutConstraint(item: minuteLabel, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: secondLabel, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: wordLabelMinutes, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: wordLabelSeconds, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0).isActive = true

        // Position labels vertically
        NSLayoutConstraint(item: wordLabelMinutes, attribute: .bottom,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerY,
                           multiplier: 1.0, constant: spacer).isActive = true
        NSLayoutConstraint(item: minuteLabel, attribute: .bottom,
                           relatedBy: .equal,
                           toItem: wordLabelMinutes, attribute: .top,
                           multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: secondLabel, attribute: .top,
                           relatedBy: .equal,
                           toItem: timeView, attribute: .centerY,
                           multiplier: 1.0, constant: spacer).isActive = true
        NSLayoutConstraint(item: wordLabelSeconds, attribute: .top,
                           relatedBy: .equal,
                           toItem: secondLabel, attribute: .bottom,
                           multiplier: 1.0, constant: 0.0).isActive = true
    }


    @objc private func handleTap() {
        print("Screen tapped.")

//        drainBucket()

    }



    //MARK: - ViewController methods

    override func viewDidAppear(_ animated: Bool) {
        drawBucketOutline()
        setUpMeasureLabels()
//        fillBucket()
        setUpTimeView()

    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if bucketView.frame.width > 0.0 {
            setUpReplicatorLayer()
            bucketView.layer.addSublayer(replicatorLayer)
            setUpInstanceLayer()
            replicatorLayer.addSublayer(instanceLayer)
            positionMeasureLabels()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

    }

}

