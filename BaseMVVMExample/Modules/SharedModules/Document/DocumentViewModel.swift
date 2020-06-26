//
//  DocumentDocumentViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol DocumentViewModelProtocol: BaseViewModelProtocol {
    var router: DocumentRouterProtocol { get }
    var isLoading: BehaviorSubject<Bool> { get }
    var documentItem: Variable<DocumentItem?> { get }
    var documentLocalUrl: PublishSubject<URL?> { get }
    var title: String { get }
    
    func viewDidRequestSharing()
    func removeLocalFile()
}

///
final class DocumentViewModel: BaseViewModel, DocumentViewModelProtocol {
    
    let router: DocumentRouterProtocol
    private let fileId: Int
    let isLoading = BehaviorSubject<Bool>(value: false)
    let documentItem = Variable<DocumentItem?>(nil)
    let documentLocalUrl = PublishSubject<URL?>()
    let title: String
    
    private lazy var filesService: FilesServiceProtocol = FilesService()
    private lazy var localFilesStorageService: LocalFileStorageServiceProtocol = LocalFileStorageService()
    
    /**
     */
    init(router: DocumentRouterProtocol, fileId: Int, title: String) {
        self.router = router
        self.fileId = fileId
        self.title = title
        super.init()
        setupBindings()
        loadFile()
    }
    
    private func setupBindings() {
        documentLocalUrl.map { $0 == nil ? nil : DocumentItem(itemURL: $0) }
            .bind(to: documentItem)
            .disposed(by: disposeBag)
    }
    
    /**
     */
    private func loadFile() {
        isLoading.onNext(true)
        filesService.getFile(with: fileId)
            .takeUntil(rx.deallocated)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .flatMapLatest { data in
                self.localFilesStorageService.saveFile(data: data, name: self.title, at: .temp)
            }
            .subscribe(onNext: { localUrl in
                self.isLoading.onNext(false)
                self.documentLocalUrl.onNext(localUrl)
            }, onError: { error in
                self.isLoading.onNext(false)
                self.documentLocalUrl.onNext(nil)
                self.router.present(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    /**
     */
    func viewDidRequestSharing() {
        guard let fileUrl = documentItem.value?.previewItemURL else { return }
        router.share(fileAt: fileUrl)
    }
    
    /**
     Removes
     */
    func removeLocalFile() {
        guard let fileUrl = documentItem.value?.previewItemURL else { return }
        localFilesStorageService.removeFile(at: fileUrl).subscribe().disposed(by: disposeBag)
    }
}
