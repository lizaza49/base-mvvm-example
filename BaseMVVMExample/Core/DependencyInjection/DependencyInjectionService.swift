//
//  DependencyInjectionService.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 22/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

protocol DependencyInjectionServiceProtocol {
	func resolve<T>(type: T.Type) -> T?
}

final class DependencyInjectionService: DependencyInjectionServiceProtocol {
	private var singletone: Any?
	private var factory: () -> Any?
	private var isSingleton: Bool
	private var isFactoryPerformed: Bool = false
	
	func resolve<T>(type: T.Type) -> T? {
		if isSingleton {
			if !isFactoryPerformed {
				singletone = factory()
				isFactoryPerformed = true
			}
			return singletone as? T
		} else {
			return factory() as? T
		}
	}
	
	init(singleton: Bool = false, factory: @escaping () -> Any?) {
		self.isSingleton = singleton
		self.factory = factory
	}
}
