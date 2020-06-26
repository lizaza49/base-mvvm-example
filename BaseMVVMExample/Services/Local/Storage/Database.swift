//
//  DatabaseService.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RealmSwift

///
class Database {
    
    private static var instance: Database!
    
    private static let schemaVersion: UInt64 = 1
    static let configuration = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: schemaVersion,
        
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < schemaVersion + 1) {
                
            }
    })
    
    class var shared: Database {
        get {
            if (instance == nil) {
                instance = Database()
            }
            return instance
        }
    }
    
    init() {
        self.realm = try! Realm(configuration: Database.configuration)
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    ///
    private var realm: Realm!
    
    /**
     */
    func save(_ object: Object, update: Bool = true, completion: (() -> Void)? = nil) {
        try! realm.write {
            realm.add(object, update: update)
            try! realm.commitWrite()
            completion?()
        }
    }
    
    /**
     */
    func save(_ objects: [Object], update: Bool = true, completion: (() -> Void)? = nil) {
        try! realm.write {
            realm.add(objects, update: update)
            try! realm.commitWrite()
            completion?()
        }
    }
    
    /**
     */
    func refreshAll<T: Object>(_ type: T.Type, with objects: [T], completion: (() -> Void)? = nil) throws {
        let objectsToDelete: Results<T> = fetch(type)
        try realm.write {
            realm.delete(objectsToDelete)
            realm.add(objects, update: false)
            try realm.commitWrite()
            completion?()
        }
    }
    
    /**
     */
    private func fetch<T: Object>(_ type: T.Type, filter: String? = nil, sort: SortDescriptor? = nil) -> Results<T> {
        var results = realm.objects(type)
        if let filter = filter {
            results = results.filter(filter)
        }
        if let sort = sort {
            results = results.sorted(byKeyPath: sort.keyPath, ascending: sort.ascending)
        }
        return results
    }
    
    /**
     */
    func fetch<T: Object>(_ type: T.Type, filter: String? = nil, sort: SortDescriptor? = nil) -> Array<T> {
        let results: Results<T> = fetch(type, filter: filter, sort: sort)
        return Array(results)
    }
    
    /**
     */
    func fetchFirst<T: Object>(_ type: T.Type, filter: String? = nil, sort: SortDescriptor? = nil) -> T? {
        return fetch(type, filter: filter, sort: sort).first
    }
    
    /**
     */
    func delete(_ object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    /**
     */
    func delete(_ objects: [Object]) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    /**
     */
    func deleteAll<T: Object>(_ type: T.Type) {
        let objects: Results<T> = fetch(type)
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    /**
     */
    func deleteAll() {
        try! realm.write {
            if realm.isEmpty {
                realm.deleteAll()
            }
        }
    }
    
    /**
     */
    func copy<T: Object> (_ object: T, completion: (T) -> Void) {
        try! realm.write {
            completion(realm.create(T.self, value: object))
        }
    }
    
    /**
     */
    func write(block: () -> Void, completion: (() -> Void)? = nil) throws {
        try realm.write {
            block()
            try realm.commitWrite()
            completion?()
        }
    }
    
    /**
     */
    func resolve<T: ThreadConfined>(_ object: ThreadSafeReference<T>) -> T? {
        return realm.resolve(object)
    }
    
    /**
     */
    func add<T: Object>(_ object: T, update: Bool = true, inWriteTransaction: Bool = true) {
        if inWriteTransaction {
            do {
                try realm.write {
                    realm.add(object, update: update)
                }
            }
            catch { DDLogError(context: .evna, message: "runtime_error", params: [ "file" : #file, "function" : #function ], error: error) }
        }
        else {
            realm.add(object)
        }
    }
}
