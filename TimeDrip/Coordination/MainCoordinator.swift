//
//  MainCoordinator.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 1/27/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        if UserDefaults.standard.bool(forKey: Defaults.AppDefaults.startOnSavedList) {
            let vc1 = InitialViewController.instantiate()
            vc1.coordinator = self
            navigationController.pushViewController(vc1, animated: false)
            let vc2 = SavedTimersTableViewController.instantiate()
            vc2.coordinator = self
            navigationController.pushViewController(vc2, animated: true)
        } else {
            let vc = InitialViewController.instantiate()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: false)
        }
    }

    func pushSimpleTimer(timer: UnsavedTimer) {
        let vc = SimpleTimerViewController.instantiate()
        print("PushSimpleTimer, Unsaved Timer")

        vc.coordinator = self
        vc.minutesSet = timer.minutesSet
        vc.secondsSet = timer.secondsSet
        vc.bucketFillColor = timer.color
        vc.pausable = timer.pausable
        vc.cancelable = timer.cancelable
        vc.alertSound = timer.sound
        vc.loopAudio = timer.loopAudio
        vc.autoStart = timer.autoStart
        vc.timerName = "Timer"

        navigationController.pushViewController(vc, animated: true)

    }

    func pushSettings() {
        let vc = SettingsViewController.instantiate()
        vc.coordinator = self
        vc.title = "Settings"
        navigationController.pushViewController(vc, animated: true)
    }

    func pushCredits() {
        let vc = CreditsTableViewController.instantiate()
        vc.coordinator = self
        vc.title = "Credits"
        navigationController.pushViewController(vc, animated: true)
    }

    func pushDefaultSettings() {
        let vc = EditTimerViewController.instantiate()
        vc.coordinator = self
        vc.mode = .prefs
        vc.title = "Default Settings"
        navigationController.pushViewController(vc, animated: true)
    }

    func pushEditTimer(timer: SavedTimer) {
        let vc = EditTimerViewController.instantiate()
        vc.coordinator = self
        vc.mode = .edit
        vc.thisTimer = timer
        vc.minutesSet = timer.minutesSet
        vc.secondsSet = timer.secondsSet
        vc.color = UIColor.init(hexString: timer.hexColor) ?? UIColor.gray
        vc.origPausable = timer.pausable
        vc.origAutoStart = timer.autoStart
        vc.timeText = "\(timer.minutesSet) min"
        vc.timerName = timer.name
        navigationController.pushViewController(vc, animated: true)
    }

    func pushSavedTimerList() {
        let vc = SavedTimersTableViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func createNewTimer() {
        let vc = EditTimerViewController.instantiate()
        vc.coordinator = self
        vc.mode = .add
        navigationController.pushViewController(vc, animated: true)
    }

    func createSingleUseTimer() {
        let vc = EditTimerViewController.instantiate()
        vc.coordinator = self
        vc.mode = .singleUse
        vc.title = "Single Use Timer"
        navigationController.pushViewController(vc, animated: true)
    }

}
