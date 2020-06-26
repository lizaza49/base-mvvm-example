//
//  RemoteItemPickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 18/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol RemoteItemPickerViewModelProtocol: BaseViewModelProtocol {
    var router: RemoteItemPickerRouterProtocol { get }
    var screenTitle: String { get }
    var searchQuery: BehaviorSubject<String?> { get }
    var searchResults: BehaviorSubject<[RemoteItemPickerCellViewModelProtocol]> { get }
    var pickedItem: BehaviorSubject<SearchableRemoteItemProtocol?> { get }
    var doneTapControlEvent: PublishSubject<Void> { get }
    
    func viewDidSelectItem(at index: Int)
}

///
class RemoteItemPickerViewModel<SearchableItemType: SearchableRemoteItemProtocol>: BaseViewModel, RemoteItemPickerViewModelProtocol {
    
    let router: RemoteItemPickerRouterProtocol
    private var availableOptions: [SearchableItemType] = []
    
    let screenTitle: String
    let searchQuery: BehaviorSubject<String?>
    let searchResults = BehaviorSubject<[RemoteItemPickerCellViewModelProtocol]>(value: [])
    let pickedItem = BehaviorSubject<SearchableRemoteItemProtocol?>(value: nil)
    let doneTapControlEvent = PublishSubject<Void>()
    
    private var strategy: RemoteItemPickerStrategy
    
    init(router: RemoteItemPickerRouterProtocol,
         strategy: RemoteItemPickerStrategy,
         screenTitle: String,
         initialValue: String,
         output: Variable<SearchableItemType?>) {
        self.router = router
        self.strategy = strategy
        self.screenTitle = screenTitle
        self.searchQuery = BehaviorSubject(value: initialValue)
        super.init()
        setupObservers(output: output)
        self.strategy.launch()
    }
    
    /**
     */
    private func setupObservers(output: Variable<SearchableItemType?>) {
        pickedItem.asObservable()
            .skipUntil(doneTapControlEvent)
            .map { $0 as? SearchableItemType }
            .skipNil()
            .bind(to: output)
            .disposed(by: disposeBag)
        
        searchQuery.asObservable()
            .map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !($0 ?? "").isEmpty }
            .debounce(strategy.debounce, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: loadResults)
            .disposed(by: disposeBag)
        
        searchQuery.asObservable()
            .map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { ($0 ?? "").isEmpty }
            .subscribe(onNext: loadResults)
            .disposed(by: disposeBag)
        
        doneTapControlEvent.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.pickedItem.emit()
                self.router.pop()
            }).disposed(by: disposeBag)
        
        strategy.onReady.subscribe(onNext: { _ in
            self.loadResults(query: (try? self.searchQuery.value()) ?? nil)
        }).disposed(by: disposeBag)
    }
    
    /**
     */
    private func loadResults(query: String?) {
        let query = query ?? ""
        let filterSequence: Observable<[SearchableItemType]> = strategy.filterResults(with: query)
        filterSequence.retryWhen { (error) -> Observable<[SearchableItemType]> in
            let sequence: Observable<[SearchableItemType]> = error.flatMap { generatedError -> Observable<[SearchableItemType]> in
                if query != (try? self.searchQuery.value()) {
                    return self.strategy.filterResults(with: query)
                }
                else {
                    return Observable<[SearchableItemType]>.error(generatedError)
                }
            }
            return sequence
            }
            .filter { _ in
                return query == (try? self.searchQuery.value())
            }
            .subscribe(
                onNext: { self.configureSearchResults(with: $0, query: query) },
                onError: {
                    if let error = $0 as? RGSError,
                        case .parsingError(let code) = error,
                        code.isSuccess{
                        self.configureSearchResults(with: [], query: query)
                        return
                    }
                    self.router.present(error: $0)
            })
            .disposed(by: disposeBag)
    }
    
    /**
     */
    private func configureSearchResults(with items: [SearchableItemType], query: String) {
        pickedItem.onNext(nil)
        availableOptions = items
        self.searchResults.onNext(items.map { RemoteItemPickerCellViewModel(text: $0.name, query: query) })
    }
    
    /**
     */
    func viewDidSelectItem(at index: Int) {
        guard (0 ..< availableOptions.count) ~= index else { return }
        pickedItem.onNext(availableOptions[index])
    }
}
