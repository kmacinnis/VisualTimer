//
//  InitialViewController.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 4/19/18.
//  Copyright © 2018 Kate MacInnis. All rights reserved.
//

import UIKit
import RealmSwift

class InitialViewController: UIViewController {

    let defaults = UserDefaults.standard

    @IBOutlet weak var oneTimeView: RoundedView!

    @IBOutlet weak var savedListView: RoundedView!

    @IBOutlet weak var preferenceView: RoundedView!

    @objc func toSingleUseTimer(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toSingleUseTimer", sender: self)
    }

    @objc func toSavedTimerList(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toSavedTimerList", sender: self)
    }

    @objc func toPreferences(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toPreferenceScreen", sender: self)
    }

    func firstLaunch()->Bool{
        if let _ = defaults.string(forKey: "hasLaunchedBefore"){
            print("App has launched before")
            return true
        } else {
            defaults.set(true, forKey: "hasLaunchedBefore")
            print("First time launching app")
            return false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapTop = UITapGestureRecognizer(target: self, action:  #selector(self.toSingleUseTimer))
        self.oneTimeView.addGestureRecognizer(tapTop)

        let tapMiddle = UITapGestureRecognizer(target: self, action: #selector(self.toSavedTimerList(sender:)))
        self.savedListView.addGestureRecognizer(tapMiddle)

        let tapBottom = UITapGestureRecognizer(target: self, action: #selector(self.toPreferences(sender:)))
        self.preferenceView.addGestureRecognizer(tapBottom)

        if firstLaunch() {
            defaults.set(false, forKey: "pausable")
            defaults.set(true, forKey: "autoStart")
            defaults.set(true, forKey: "cancelable")
            defaults.set("#C390D4", forKey: "color")
            defaults.set("simple", forKey: "style")

            let timerOne = SavedTimer()
            let realm = try! Realm()
            do {
                try realm.write {
                    timerOne.name = "Simple Timer Example"
                    timerOne.hoursSet = 0
                    timerOne.minutesSet = 5
                    timerOne.secondsSet = 0
                    timerOne.timerType = .simple
                    timerOne.autoStart = true
                    timerOne.pausable = false
                    timerOne.hexColor = "#FF8F17"

                }
            } catch {
                print("Error writing to database: \(error)")
            }
//            @objc dynamic var name: String = ""
//            @objc dynamic var hoursSet: Int = 0
//            @objc dynamic var minutesSet: Int = 0
//            @objc dynamic var secondsSet: Int = 0
//            @objc dynamic var dateCreated: Date = Date()
//            @objc dynamic var sortOrder: Int = 99
//            @objc dynamic var timerType: TimerType = .simple
//            @objc dynamic var autoStart: Bool = false
//            @objc dynamic var pausable: Bool = false
//            @objc dynamic var hexColor: String = ""









        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toSingleUseTimer":
            let destinationVC = segue.destination as! EditTimerViewController
            destinationVC.mode = .singleUse
            destinationVC.title = "Single Use Timer"
        case "toPreferenceScreen":
            let destinationVC = segue.destination as! EditTimerViewController
            destinationVC.mode = .prefs
            destinationVC.title = "Preferences"
        default:
            ()
        }
    }


}
