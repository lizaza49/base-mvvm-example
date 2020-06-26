//
//  DependencyInjection.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 22/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

public protocol DependencyInjectionProtocol {
	static var container: DependencyInjectionContainer { get }
}

public class DependencyInjection: DependencyInjectionProtocol {
	public static var container: DependencyInjectionContainer = DependencyInjectionContainer(diClass: DependencyInjection.self, diRegistrationFile: "DependencyInjectionRegistration")
}
