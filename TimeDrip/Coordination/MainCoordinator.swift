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
        let vc = InitialViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }

//    func buySubscription() {
//        let vc = BuyViewController.instantiate()
//        vc.coordinator = self
//        navigationController.pushViewController(vc, animated: true)
//    }

    func pushSimpleTimer() {
        let vc = SimpleTimerViewController.instantiate()
        //TODO: add setup
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func pushSettings() {
        let vc = SettingsViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func pushEditTimer() {
        let vc = EditTimerViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func pushSavedTimers() {
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


}
