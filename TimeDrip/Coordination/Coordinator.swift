//
//  Coordinators.swift
//  TimeDrip
//
//  Created by Kate MacInnis on 1/27/19.
//  Copyright © 2019 Kate MacInnis. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
