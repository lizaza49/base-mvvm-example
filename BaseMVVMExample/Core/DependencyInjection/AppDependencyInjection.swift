//
//  AppDependencyInjection.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 22/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

public class AppDependencyInjection {

	static var container: DependencyInjectionContainer {
		return DependencyInjection.container
	}

	static func registerAll() {
		container.register(LocationServiceProtocol.self, asSingleTone: true) { LocationService() }
		container.register(OfficiesServiceProtocol.self) { OfficiesService() }
		container.register(ProfileServiceProtocol.self) { ProfileService() }
	}
}
