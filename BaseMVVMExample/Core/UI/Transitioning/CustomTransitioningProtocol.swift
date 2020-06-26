//
//  CustomTransitioningProtocol.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
enum TransitionDirection {
    case forward, backwards
}

/// Conforming UIViewControllers would be able to use `transitionManager` as `transitioningDelegate`
protocol CustomTransitioningProtocol {
    var interactive: Bool { get set }
    var transitionManager: TransitionManager? { get set }
    func transitionManager(for direction: TransitionDirection, interactive: Bool) -> TransitionManager?
}

///
extension CustomTransitioningProtocol {
    func transitionManager(for direction: TransitionDirection, interactive: Bool = false) -> TransitionManager? {
        return transitionManager
    }
}
