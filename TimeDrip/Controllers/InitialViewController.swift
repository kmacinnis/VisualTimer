//
//  InitialViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 4/19/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RealmSwift

class InitialViewController: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?
    let defaults = UserDefaults.standard

    @IBOutlet weak var oneTimeView: RoundedView!
    @IBOutlet weak var singleHourglass: UIImageView!
    @IBOutlet weak var singleTimerText: UITextView!
    
    @IBOutlet weak var savedListView: RoundedView!
    @IBOutlet weak var savedTimersText: UITextView!
    
    @IBOutlet weak var preferenceView: RoundedView!
    @IBOutlet weak var prefText: UITextView!
    
    @objc func toSingleUseTimer(sender : UITapGestureRecognizer) {
        coordinator?.createSingleUseTimer()
    }

    @objc func toSavedTimerList(sender : UITapGestureRecognizer) {
        coordinator?.pushSavedTimerList()
    }

    @objc func toPreferences(sender : UITapGestureRecognizer) {
        coordinator?.pushSettings()
    }

    func firstLaunch() -> Bool{
        if let _ = defaults.string(forKey: "hasLaunchedBefore"){
            print("App has launched before")
            return true
        } else {
            defaults.set(true, forKey: "hasLaunchedBefore")
            print("First time launching app")
            return false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Set up gesture recognizers
        let tapSingle = UITapGestureRecognizer(target: self, action:  #selector(self.toSingleUseTimer))
        self.oneTimeView.addGestureRecognizer(tapSingle)

        let tapList = UITapGestureRecognizer(target: self, action: #selector(self.toSavedTimerList(sender:)))
        self.savedListView.addGestureRecognizer(tapList)

        let tapSettings = UITapGestureRecognizer(target: self, action: #selector(self.toPreferences(sender:)))
        self.preferenceView.addGestureRecognizer(tapSettings)

//        if firstLaunch() {
//            defaults.set(false, forKey: "pausable")
//            defaults.set(true, forKey: "autoStart")
//            defaults.set(true, forKey: "cancelable")
//            defaults.set("#C390D4", forKey: "color")
//            defaults.set("simple", forKey: "style")
//
//            let timerOne = SavedTimer()
//            let realm = try! Realm()
//            do {
//                try realm.write {
//                    timerOne.name = "Simple Timer Example"
//                    timerOne.hoursSet = 0
//                    timerOne.minutesSet = 5
//                    timerOne.secondsSet = 0
//                    timerOne.timerType = .simple
//                    timerOne.autoStart = true
//                    timerOne.pausable = false
//                    timerOne.hexColor = "#FF8F17"
//
//                }
//            } catch {
//                print("Error writing to database: \(error)")
//            }
//
//        }

    }



}
