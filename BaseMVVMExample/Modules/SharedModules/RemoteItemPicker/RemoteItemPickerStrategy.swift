//
//  RemoteItemPickerStrategy.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol RemoteItemPickerStrategy {
    var onReady: PublishSubject<Void> { get }
    var debounce: TimeInterval { get }
    func filterResults<Item>(with query: String) -> Observable<[Item]> where Item: SearchableRemoteItemProtocol
    func launch()
}

///
class RemoteItemPickerQueryStrategy: RemoteItemPickerStrategy {
    private let service: RemoteItemSearchServiceProtocol
    let onReady: PublishSubject<Void> = PublishSubject()
    lazy var debounce: TimeInterval = 0.5
    
    init(service: RemoteItemSearchServiceProtocol) {
        self.service = service
    }
    
    func filterResults<Item>(with query: String) -> Observable<[Item]> where Item: SearchableRemoteItemProtocol {
        let adjustedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !adjustedQuery.isEmpty else {
            return Observable.just([])
        }
        return service.search(query: adjustedQuery)
    }
    
    func launch() {}
}

///
class RemoteItemPickerOnceFetchedDatasetStrategy<ItemType: SearchableRemoteItemProtocol>: RemoteItemPickerStrategy {
    
    ///
    let onReady: PublishSubject<Void> = PublishSubject()
    lazy var debounce: TimeInterval = 0
    private let fetchService: RemoteItemFetchServiceProtocol
    private let target: RemoteItemFetchTarget
    private var dataSet: [ItemType] = []
    private let numberOfAttempts = 5
    private var disposeBag = DisposeBag()
    
    /**
     */
    init(fetchService: RemoteItemFetchServiceProtocol, target: RemoteItemFetchTarget) {
        self.fetchService = fetchService
        self.target = target
    }
    
    /**
     */
    func filterResults<Item>(with query: String) -> Observable<[Item]> where Item: SearchableRemoteItemProtocol {
        guard Item.self == ItemType.self else {
            return Observable.error(RGSError.invalidInput)
        }
        let adjustedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !adjustedQuery.isEmpty else {
            return Observable.just((dataSet as? [Item]) ?? [])
        }
        let pattern = adjustedQuery.replacingOccurrences(of: " ", with: ".*")
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            return Observable.create { observer in
                DispatchQueue.global(qos: .userInitiated).async {
                    let filtered = self.dataSet
                        .filter {
                            let numberOfMatches = regex.numberOfMatches(in: $0.name.lowercased(), options: [], range: NSRange(location: 0, length: $0.name.count))
                            return numberOfMatches > 0 }
                        .sorted(by: {
                            return $0.name.lowercased().prefixIntersection(with: adjustedQuery).count > $1.name.lowercased().prefixIntersection(with: adjustedQuery).count
                        })
                        .compactMap { $0 as? Item }
                    observer.onNext(filtered)
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }
        catch {
            return Observable.error(error)
        }
    }
    
    /**
     */
    func launch() {
        let fetch: Observable<[ItemType]> = fetchService.fetch(target: target)
        fetch.retry(numberOfAttempts)
            .subscribe(onNext: { items in
                self.dataSet = items
                self.onReady.onNext(())
            }, onError: {
                Log.some($0)
            }).disposed(by: disposeBag)
    }
}


///
class RemoteItemPickerPredefinedDatasetStrategy: RemoteItemPickerStrategy {

    ///
    let onReady: PublishSubject<Void> = PublishSubject()
    lazy var debounce: TimeInterval = 0
    private let dataSet: [SearchableRemoteItemProtocol]
    
    /**
     */
    init(dataSet: [SearchableRemoteItemProtocol]) {
        self.dataSet = dataSet
    }

    /**
     */
    func filterResults<Item>(with query: String) -> Observable<[Item]> where Item: SearchableRemoteItemProtocol {
        return Observable.create { observer in
            // TODO: Implement filtering logic
            return Disposables.create()
        }
    }
    
    func launch() {}
}
