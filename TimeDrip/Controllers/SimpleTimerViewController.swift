//
//  ViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 2/13/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import CoreGraphics
import ChameleonFramework // for easy color manipulation -- may not be necessary
import AVFoundation // for alert sound

//TODO:
// * Refactor time view, making swipeable to change modes (minutes only, etc)
// * Add slight gradient to bucketfill
// * Add slight gradient to background
// * change background and line color to contrast bucketfill color
// * figure out out to retrieve timers left running after exiting
// * incorporate willanimaterotation?



class SimpleTimerViewController: UIViewController {

    //MARK: - Initialize stuff
    let bucketView = UIView()
    let bucketFillLayer = CAShapeLayer()
    let bucketLabelView = UIView()
    var labelList: [UILabel] = []
    let replicatorLayer = CAReplicatorLayer()
    let instanceLayer = CALayer()

    let bucketLineColor = UIColor.flatBlackDark.cgColor
    var bucketFillColor = UIColor.flatMint.cgColor

    let minuteLabel: UILabel = {
        let label = timeLabel("")
        return label
    }()

    let secondLabel: UILabel = {
        let label = timeLabel("")
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

    var hoursSet: Int = 0
    var minutesSet: Int = 2
    var secondsSet: Int = 0
    var hours: Int = 0
    var minutes: Int = -99
    var seconds: Int = 0
    
    var timer = Timer()
    var timerInUse: Bool = false
    var timerPaused: Bool = false
    var shouldDisplaySeconds: Bool = true

    var autoStart: Bool = false
    var pausable: Bool = true

    @IBOutlet weak var timerButton: UIButton!

    //MARK: - Timer functionality

    func runTimer() {
        if !timerInUse {
            minutes = minutesSet
            seconds = 0
            minuteLabel.text = "\(minutes)"
            secondLabel.text = "\(seconds)"
        }
        timerInUse = true
        timerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SimpleTimerViewController.updateTimer)), userInfo: nil, repeats: true)
        drainBucket()
        timerButton.setTitle("Pause", for: .normal)
    }

    func pauseTimer() {
        timer.invalidate()
        bucketFillLayer.removeAnimation(forKey: "drain")
        bucketFillLayer.path = bucketFillPath().cgPath
        timerButton.setTitle("Resume", for: .normal)
        timerPaused = true
    }


    @objc func updateTimer() {
        if minutes + seconds == 0 {
            timer.invalidate()
            AudioServicesPlayAlertSound(1030)
            return
        }
        if seconds == 0 {
            minutes -= 1
            seconds = 59
        } else {
            seconds -= 1
        }
    }

    func updateTimeDisplay() {
        minuteLabel.text = "\(minutes)"
        if minutes == 1 {
            wordLabelMinutes.text = "Minute"
        } else {
            wordLabelMinutes.text = "Minutes"
        }
        if shouldDisplaySeconds {
            secondLabel.text = "\(seconds)"
            if seconds == 1 {
                wordLabelSeconds.text = "Second"
            } else {
                wordLabelSeconds.text = "Seconds"
            }
        }
        if hoursSet > 0 {
//            hourLabel.text = "\(hours)"
//            if hours == 1 {
//                wordLabelHours.text = "Hour"
//            } else {
//                wordLabelHours.text = "Hours"
//            }
        }
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

    func setUpMeasureMarks() {
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

    func setUpBucketFill() {
        bucketView.layer.addSublayer(bucketFillLayer)
        bucketFillLayer.fillColor = bucketFillColor
        bucketFillLayer.frame = bucketView.bounds
        if timerInUse {
            bucketFillLayer.path = bucketFillPath().cgPath
        } else {
            bucketFillLayer.path = bucketFillPath(0.0).cgPath
        }
    }

    func percentFull() -> Float {
        return Float(minutes * 60 + seconds)/Float(minutesSet * 60)
    }

    func bucketFillPath(_ pd: Float? = nil) -> UIBezierPath {
        let percentDrained = pd ?? 1.0 - percentFull()
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

    func drainBucket() {
        bucketFillLayer.removeAllAnimations()
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.fromValue = bucketFillPath().cgPath
        basicAnimation.toValue = bucketFillPath(1.0).cgPath
        basicAnimation.duration = CFTimeInterval(minutes * 60 + seconds)
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        bucketFillLayer.add(basicAnimation, forKey: "drain")
    }



    func drawBucketOutline() {
        view.addSubview(bucketView)
        bucketView.backgroundColor = UIColor.clear
        let horizPadding = CGFloat(10.0)

        bucketView.layer.borderWidth = 2
        bucketView.layer.borderColor = bucketLineColor
        bucketView.translatesAutoresizingMaskIntoConstraints = false
        let bucketLeft = NSLayoutConstraint(item: bucketView, attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self.view, attribute: .leftMargin,
                                            multiplier: 1.0, constant: horizPadding)
        let bucketRight = NSLayoutConstraint(item: bucketView, attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self.view, attribute: .centerXWithinMargins,
                                             multiplier: 1.0, constant: -horizPadding)
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
                                            multiplier: 1.0, constant: horizPadding)
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

    func setUpBucket() {
        drawBucketOutline()
        setUpMeasureLabels()
        setUpBucketFill()
    }

    func setUpTimeView() {
        //TODO: Change things up, using a xib,
        // and make it swipeable to change between display modes:
        // minutes only, minutes+seconds, hours(when applicable)
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
        minuteLabel.text = "\(minutesSet)"
        secondLabel.text = "\(secondsSet)"
    }


    @objc private func handleTap() {
        print("Screen tapped.")


    }



    //MARK: - ViewController methods

    override func viewDidAppear(_ animated: Bool) {
        setUpBucket()
        setUpTimeView()


    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if bucketView.frame.width > 0.0 {
            setUpReplicatorLayer()
            bucketView.layer.addSublayer(replicatorLayer)
            setUpMeasureMarks()
            replicatorLayer.addSublayer(instanceLayer)
            positionMeasureLabels()
            if timerInUse && !timerPaused {
                drainBucket()
            }
            if autoStart && !timerInUse {
                runTimer()
            }
        }
    }

    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !pausable {
            timerButton.isHidden = true
        }

        // view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

    }

}

