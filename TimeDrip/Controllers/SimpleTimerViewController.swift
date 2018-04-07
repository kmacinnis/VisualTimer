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
// * Add slight gradient to bucketfill
// * Add slight gradient to background
// * change background and line color to contrast bucketfill color
// * figure out out to retrieve timers left running after exiting
// * incorporate viewWillTransition?



class SimpleTimerViewController: UIViewController {

    //MARK: - Initialize stuff
    let bucketView = UIView()
    let bucketFillLayer = CAShapeLayer()
    let bucketMeasureView = UIView()
    var labelList: [UILabel] = []
    let replicatorLayer = CAReplicatorLayer()
    let instanceLayer = CALayer()

    let bucketLineColor = UIColor.flatBlackDark.cgColor
    var bucketFillColor = UIColor.flatMint.cgColor

    var timerName: String = ""
    var hoursSet: Int = 0
    var minutesSet: Int = 2
    var secondsSet: Int = 0
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var minutesCeil: Int = 15

    
    var timer = Timer()
    var timerInUse: Bool = false
    var timerPaused: Bool = false
    var shouldDisplaySeconds: Bool = false
    var shouldDisplayHours: Bool = false

    var autoStart: Bool = false
    var pausable: Bool = true
    var cancelable: Bool = true
    var setUpComplete: Bool = false
    var bucketViewReady: Bool = false

    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var cancelButton: RoundedButton!

    @IBOutlet weak var bucketSpace: UIView!
    @IBOutlet weak var timeDisplaySpace: UIView!
    
    @IBOutlet weak var hourSubview: UIView!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var hourUnitLabel: UILabel!
    @IBOutlet weak var minuteSubview: UIView!
    @IBOutlet weak var minuteValueLabel: UILabel!
    @IBOutlet weak var minuteUnitLabel: UILabel!
    @IBOutlet weak var secondSubview: UIView!
    @IBOutlet weak var secondValueLabel: UILabel!
    @IBOutlet weak var secondUnitLabel: UILabel!

    //MARK: - Timer functionality

    func runTimer() {
        if !timerInUse {
            minutes = minutesSet
            minutesCeil = minutesSet
            seconds = 0
            updateTimeDisplay()
        }
        timerInUse = true
        timerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SimpleTimerViewController.updateTimer)), userInfo: nil, repeats: true)
        drainBucket()
        if pausable {
            timerButton.setTitle("Pause", for: .normal)
        } else {
            timerButton.isHidden = true //TODO: This should be somewhere else?
        }
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
            minutesCeil = 0
            timer.invalidate()
            AudioServicesPlayAlertSound(1030)
            updateTimeDisplay()
            navigationItem.hidesBackButton = false

            return
        }
        if seconds == 0 {
            minutes -= 1
            minutesCeil = minutes + 1
            seconds = 59
        } else {
            seconds -= 1
        }
        updateTimeDisplay()
    }

    func updateTimeDisplay() {
        if shouldDisplayHours {
            hourValueLabel.text = "\(hours)"
            if hours == 1 {
                hourUnitLabel.text = "Hour"
            } else {
                hourUnitLabel.text = "Hours"
            }
        }

        if shouldDisplaySeconds {
            minuteValueLabel.text = "\(minutes)"
            if minutes == 1 {
                minuteUnitLabel.text = "Minute"
            } else  {
                minuteUnitLabel.text = "Minutes"
            }

            secondValueLabel.text =  "\(seconds)"
            if seconds == 1 {
                secondUnitLabel.text = "Second"
            } else {
                secondUnitLabel.text = "Seconds"
            }
        } else {
            minuteValueLabel.text = "\(minutesCeil)"
            if minutesCeil == 1 {
                minuteUnitLabel.text = "Minute"
            } else  {
                minuteUnitLabel.text = "Minutes"
            }
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

    @IBAction func cancelButtonPressed(_ sender: Any) {
        timer.invalidate()
        self.navigationController?.popToRootViewController(animated: true)
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
            bucketMeasureView.addSubview(label)
                }
        positionMeasureLabels()
        }

    func positionMeasureLabels() {
        let vertShift = bucketView.frame.height / CGFloat(minutesSet)
        let minX = bucketMeasureView.bounds.minX + 3
        let width = bucketMeasureView.bounds.width
        let bottom = bucketMeasureView.bounds.height
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
        bucketSpace.backgroundColor = UIColor.clear
        bucketSpace.addSubview(bucketView)
        bucketView.backgroundColor = UIColor.clear
        let horizPadding = CGFloat(25)
        let vertPadding = CGFloat(20)




        bucketView.layer.borderWidth = 2
        bucketView.layer.borderColor = bucketLineColor
        bucketView.translatesAutoresizingMaskIntoConstraints = false
        let bucketLeft = NSLayoutConstraint(item: bucketView, attribute: .left,
                                            relatedBy: .equal,
                                            toItem: bucketSpace, attribute: .leftMargin,
                                            multiplier: 1.0, constant: horizPadding)
        let bucketRight = NSLayoutConstraint(item: bucketView, attribute: .right,
                                             relatedBy: .equal,
                                             toItem: bucketSpace, attribute: .rightMargin,
                                             multiplier: 1.0, constant: -horizPadding)
        let bucketTop = NSLayoutConstraint(item: bucketView, attribute: .top,
                                           relatedBy: .equal,
                                           toItem: bucketSpace, attribute: .top,
                                           multiplier: 1.0, constant: vertPadding)
        let bucketBottom = NSLayoutConstraint(item: bucketView, attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bucketSpace, attribute: .bottom,
                                              multiplier: 1.0, constant: -3*vertPadding)
        NSLayoutConstraint.activate([bucketTop, bucketBottom, bucketLeft, bucketRight])

        bucketSpace.addSubview(bucketMeasureView)
        bucketMeasureView.translatesAutoresizingMaskIntoConstraints = false
        bucketMeasureView.backgroundColor = UIColor.clear
        let labelLeft = NSLayoutConstraint(item: bucketMeasureView, attribute: .left,
                                           relatedBy: .equal,
                                           toItem: bucketView, attribute: .right,
                                           multiplier: 1.0, constant: 0.0)
        let labelRight = NSLayoutConstraint(item: bucketMeasureView, attribute: .right,
                                            relatedBy: .equal,
                                            toItem: bucketSpace, attribute: .rightMargin,
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

        bucketViewReady = true

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


    @objc private func handleTap() {
        shouldDisplaySeconds = !shouldDisplaySeconds
//        secondSubview.isHidden = !shouldDisplaySeconds
        self.updateTimeDisplay()
        UIView.animate(withDuration: 0.5) {
            self.secondSubview.isHidden = !(self.shouldDisplaySeconds)
        }


    }



    //MARK: - ViewController methods

//    override func viewDidAppear(_ animated: Bool) {
//        setUpBucket()
//    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if bucketViewReady {
            setUpReplicatorLayer()
            bucketView.layer.addSublayer(replicatorLayer)
            setUpMeasureMarks()
            replicatorLayer.addSublayer(instanceLayer)
            positionMeasureLabels()
            if autoStart && !timerInUse {
                runTimer()
            }
            if timerInUse && !timerPaused {
                drainBucket()
            }
        }
    }

//    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//
//    }


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = timerName
        if !pausable && autoStart {
            timerButton.isHidden = true
        }
        hourValueLabel.text = "\(hoursSet)"
        minuteValueLabel.text = "\(minutesSet)"
        secondValueLabel.text = "\(secondsSet)"
        if hoursSet == 0 {
            hourSubview.isHidden = true
            shouldDisplayHours = false
        }

        secondSubview.isHidden = !shouldDisplaySeconds


        timeDisplaySpace.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        setUpBucket()

    }

}

