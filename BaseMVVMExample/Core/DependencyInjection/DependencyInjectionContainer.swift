//
//  DependencyInjectionContainer.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 22/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

public class DependencyInjectionContainer {
	
	private var diRegistration: [String: Any]?
	
	private var services: [AnyHashable: [DependencyInjectionServiceProtocol]] = [:]
	
	public init(diClass: AnyClass, diRegistrationFile: String?) {
		let bundle = Bundle(for: diClass)
		if let diRegistrationFile = diRegistrationFile, let path = bundle.path(forResource: diRegistrationFile, ofType: "plist") {
			diRegistration = NSDictionary(contentsOfFile: path) as? [String: Any]
		}
	}
	
	public func register<T>(_ type: T.Type, asSingleTone: Bool = false, factory: @escaping () -> T) {
		let service = DependencyInjectionService(singleton: asSingleTone, factory: factory)
		
		let key = makeKey(type: type)
		if var servicesAtType = services[key] {
			servicesAtType.append(service)
			services[key] = servicesAtType
		} else {
			services[key] = [service]
		}
	}
	
	public func resolve<T>(_ type: T.Type) -> T? {
		let key = makeKey(type: type)
		guard let service = services[key] else {
			fatalError("\(key) not registered in DI")
		}
		return service.map({ (registeredService) -> T? in
			guard let instance = registeredService.resolve(type: type) else { return nil }
			let namespace = DependencyInjectionContainer.namespace(from: instance)
			
			guard !inRegistryList(type: key) || isAllowed(type: key, namespace: namespace) else {
				debugPrint("\(instance) is not allowed in DI of \(namespace)")
				return nil
			}
			services[key] = [registeredService]
			return instance
		}).compactMap { $0 }.first
	}
	
	private func makeKey<T>(type: T.Type) -> String {
		return String(describing: type)
	}
	
	private func inRegistryList(type: String) -> Bool {
		return diRegistration?[type] != nil
	}
	
	private func isAllowed(type: String, namespace: String?) -> Bool {
		let allowedNamespace = diRegistration?[type] as? String
		return namespace == allowedNamespace
	}
	
	private static func namespace(from object: Any) -> String {
		return String(reflecting: object).trimmingCharacters(in: CharacterSet(charactersIn: "<>")).components(separatedBy: ".").first ?? ""
	}
}
