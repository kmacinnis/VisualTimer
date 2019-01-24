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
import SwiftySound // for alert sound

//TODO:
// * Fix rotation problem (incorporate viewWillTransition?)
// * applicationWillEnterBackground/applicationWillEnterForeground
//      - https://stackoverflow.com/a/46877212/731985



class SimpleTimerViewController: UIViewController {

    //MARK: - Initialize stuff

    var bucketLineColor: UIColor = UIColor.black
    var bucketFillColor: CGColor = UIColor.gray.cgColor

    var timerName: String = ""
    var hoursSet: Int = 0
    var minutesSet: Int = 2
    var secondsSet: Int = 0
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var minutesCeil: Int = 0

    
    var timer = Timer()
    var timerInUse: Bool = false
    var timerPaused: Bool = false
    var shouldDisplaySeconds: Bool = false
    var shouldDisplayHours: Bool = false

    var alertSound: String = ""
    var autoStart: Bool = false
    var pausable: Bool = true
    var cancelable: Bool = true
    var loopAudio: Bool = true
    var runTimerWhenReady: Bool = false
    var setUpComplete: Bool = false

    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var cancelButton: RoundedButton!

    @IBOutlet weak var bucketSpace: BucketSpace!
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
        print("run timer")
        if !timerInUse {
            minutes = minutesSet
            minutesCeil = minutesSet
            seconds = 0
            updateTimeDisplay()
        }
        timerInUse = true
        timerPaused = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SimpleTimerViewController.updateTimer)), userInfo: nil, repeats: true)
        bucketSpace.drainBucket()
        if pausable {
            timerButton.setTitle("Pause", for: .normal)
        } else {
            timerButton.isHidden = true
        }
        cancelButton.isHidden = !cancelable
    }

    func pauseTimer() {
        timer.invalidate()
        bucketSpace.bucketFillLayer.removeAnimation(forKey: "drain")
        bucketSpace.bucketFillLayer.path = bucketSpace.bucketFillPath().cgPath
        timerButton.setTitle("Resume", for: .normal)
        timerPaused = true
    }

    @objc func updateTimer() {

        if minutes + seconds == 0 {
            minutesCeil = 0
            timer.invalidate()
            let numLoops = loopAudio ? -1 : 0
            print("sounds/\(alertSound)")
            Sound.play(file: "sounds/\(alertSound)", fileExtension: "wav", numberOfLoops: numLoops)
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
        print("Timer button pressed")
        // timerPaused or not timerInUse
        if timerPaused || !timerInUse {
            runTimer()
        } else {
            pauseTimer()
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("Cancel button pressed")
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = false
        bucketSpace.setNeedsLayout()
        bucketSpace.layoutIfNeeded()
        bucketSpace.adjustBucketInsides()
        Sound.stopAll()
        timer.invalidate()

        bucketSpace.stopAnimations()
        bucketSpace.updateFillPath()
        timerInUse = false
        timerPaused = false
        timerButton.isHidden = false
        timerButton.setTitle("Restart", for: .normal)
        cancelButton.isHidden = true

    }


    func percentRun() -> Float {
        return Float(minutes * 60 + seconds)/Float(minutesSet * 60)
    }


    @objc private func handleTap() {
        print("HandleTap")
        shouldDisplaySeconds = !shouldDisplaySeconds
        self.updateTimeDisplay()
        UIView.animate(withDuration: 0.5) {
            self.secondSubview.isHidden = !(self.shouldDisplaySeconds)
        }
    }

    //MARK: - ViewController methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        runTimerWhenReady = autoStart
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        Sound.stopAll()
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        bucketSpace.parentVC = self
        navigationItem.title = timerName

        if !pausable && autoStart {
            timerButton.isHidden = true
        }
        cancelButton.isHidden = !cancelable
        hourValueLabel.text = "\(hoursSet)"
        minuteValueLabel.text = "\(minutesSet)"
        secondValueLabel.text = "\(secondsSet)"
        if hoursSet == 0 {
            hourSubview.isHidden = true
            shouldDisplayHours = false
        }
        secondSubview.isHidden = !shouldDisplaySeconds
        timeDisplaySpace.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        if bucketFillColor == UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor {
            view.backgroundColor = UIColor.gray
        }

        bucketSpace.setUpBucket()
        if runTimerWhenReady {
            runTimer()
            runTimerWhenReady = false
        }
        if timerInUse && !timerPaused {
            bucketSpace.drainBucket()
        }

    }

    override func viewDidLayoutSubviews() {
        // Handles rotation
        super.viewDidLayoutSubviews()
        bucketSpace.setNeedsLayout()
        bucketSpace.layoutIfNeeded()
        bucketSpace.adjustBucketInsides()
        pauseTimer()
        runTimer()
    }


}


