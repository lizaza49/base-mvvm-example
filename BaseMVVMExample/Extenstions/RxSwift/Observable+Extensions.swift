//
//  Observable+Extensions.swift
//  BaseMVVMExample
//
//  Created by Admin on 01/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
extension ObservableType where E: Equatable {
  
    /**
     */
    func skipRepeats() -> Observable<Self.E> {
        typealias Accumulator = (prev: E?, next: E)
        let observable: Observable<Accumulator?> = self
            .scan(nil, accumulator: {
                return (prev: $0?.next, next: $1)
            })
        return observable
            .skipNil()
            .filter { $0.prev != $0.next }
            .map { $0.next }
    }
}

///
protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

///
extension Optional: OptionalType {
    var optional: Wrapped? { return self }
}

///
extension ObservableType where E: OptionalType {
    
    /**
     */
    func skipNil() -> Observable<Self.E.Wrapped> {
        return flatMap { Observable.from(optional: $0.optional) }
    }
}
