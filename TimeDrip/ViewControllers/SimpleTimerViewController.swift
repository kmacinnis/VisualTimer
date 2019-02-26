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

//TODO: Checklist
// * Fix rotation problem (incorporate viewWillTransition?)
// * applicationWillEnterBackground/applicationWillEnterForeground
//      - https://stackoverflow.com/a/46877212/731985
// * BUG: Cancelling timer leaves graphic moving
// * BUG: Timer re-runs after stopping sometimes?
// * BUG: Getting out after finishing runs timer again
// * check preference Dark background for light colors




class SimpleTimerViewController: UIViewController, Storyboarded {

    enum TimerState {
        case running
        case paused
        case finished
        case void
    }

    //MARK: - Initialize stuff
    weak var coordinator: MainCoordinator?
    
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
    var timerState: TimerState = .void
    var shouldDisplaySeconds: Bool = true
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
        if timerState == .void {
            minutes = minutesSet
            minutesCeil = minutesSet
            seconds = 0
            updateTimeDisplay()
        }
        timerState = .running
        updateButtons()
        print("Create timer object")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SimpleTimerViewController.updateTimer)), userInfo: nil, repeats: true)
        bucketSpace.drainBucket()
    }

    func pauseTimer() {
        timer.invalidate()
        bucketSpace.bucketFillLayer.removeAnimation(forKey: "drain")
        bucketSpace.bucketFillLayer.path = bucketSpace.bucketFillPath().cgPath
        timerState = .paused
        updateButtons()
    }


    /// This is used to set the timer to void, and clear everything for a restart
    func voidTimer() {
        timer.invalidate()
        hours = 0
        minutes = 0
        seconds = 0
        bucketSpace.bucketFillLayer.removeAnimation(forKey: "drain")
        bucketSpace.bucketFillLayer.path = bucketSpace.bucketFillPath(1.0).cgPath
        Sound.stopAll()
        timer.invalidate()

        timerState = .void
        updateButtons()
        updateTimeDisplay()
    }

    /// Performs the work to keep the screen reflecting the timer
    @objc func updateTimer() {

        if minutes + seconds == 0 {
            minutesCeil = 0
            timer.invalidate()
            let numLoops = loopAudio ? -1 : 0
            print("sounds/\(alertSound)")
            Sound.category = .soloAmbient
            Sound.play(file: "sounds/\(alertSound)", fileExtension: "wav", numberOfLoops: numLoops)
            updateTimeDisplay()
            navigationItem.hidesBackButton = false
            timerState = .finished
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

    func updateButtons() {
        switch timerState {
        case .running:
            // timerButton.isHidden = !pausable
            timerButton.alpha = pausable ? 1.0 : 0.3
            timerButton.setTitle("Pause", for: .normal)
            // cancelButton.isHidden = !cancelable
            cancelButton.alpha = cancelable ? 1.0 : 0.3
        case .paused:
            timerButton.isHidden = false  // must show timer button to be able to resume
            timerButton.alpha = 1.0
            timerButton.setTitle("Resume", for: .normal)
            // cancelButton.isHidden = !cancelable
            cancelButton.alpha = cancelable ? 1.0 : 0.3
        case .void:
            timerButton.isHidden = false
            timerButton.alpha = 1.0
            timerButton.setTitle("Start", for: .normal)
            // cancelButton.isHidden = true
            cancelButton.alpha = 0.3
        case .finished:
            //TODO: possibly this should depend on whether the sound repeats??
            timerButton.isHidden = false
            timerButton.alpha = 1.0
            timerButton.setTitle("Done", for: .normal)
            // cancelButton.isHidden = true
            cancelButton.alpha = 0.3
        }
    }

    @IBAction func timerButtonPressed(_ sender: Any) {
        print("Timer button pressed")
        switch timerState {
        case .running:
            pauseTimer()
        case .paused, .void:
            runTimer()
        case .finished:
            voidTimer()
        }

    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("Cancel button pressed")
//        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = false

        voidTimer()
        autoStart = false

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

    override func viewDidLoad() {
        super.viewDidLoad()
        bucketSpace.parentVC = self
        navigationItem.title = timerName

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
        if timerState == .running {
            bucketSpace.drainBucket()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.isNavigationBarHidden = true
        navigationItem.hidesBackButton = true
        UIApplication.shared.isIdleTimerDisabled = true
        runTimerWhenReady = autoStart
    }

//    override func viewDidLayoutSubviews() {
//        // Handles rotation
//        super.viewDidLayoutSubviews()
//        bucketSpace.setNeedsLayout()
//        bucketSpace.layoutIfNeeded()
//        bucketSpace.adjustBucketInsides()
//        //        pauseTimer()
//        //        runTimer()
//        //TODO: what's up with pause/run above? was that a clunky way to force update the bucket?
//    }

//    viewDidLayoutSubviews()

//    viewDidAppear(_ animated: Bool)

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
        Sound.stopAll()
    }



}


