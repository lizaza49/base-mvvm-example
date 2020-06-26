//
//  LocalFileStorageService.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
enum LocalFilesStorageDirectory: String {
    case documents, temp
}

///
protocol LocalFileStorageServiceProtocol {
    func saveFile(data: Data, name: String, at directory: LocalFilesStorageDirectory) -> Observable<URL?>
    @discardableResult func removeFile(at url: URL) -> Observable<Void>
}

///
class LocalFileStorageService: LocalFileStorageServiceProtocol {
    
    private lazy var fileManager = FileManager.default
    
    /**
     */
    func saveFile(data: Data, name: String, at directory: LocalFilesStorageDirectory) -> Observable<URL?> {
        return Observable.create { observer in
            do {
                let documentDirectory = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let name = name.convertedToLowercasedLatin() ?? name
                let fullRelativeUrl = directory.rawValue + "/" + name
                let fileURL = documentDirectory.appendingPathComponent(fullRelativeUrl)
                
                let directoryUrl = documentDirectory.appendingPathComponent(directory.rawValue)
                if !self.fileManager.fileExists(atPath: directoryUrl.path) {
                    try self.fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
                }
                try data.write(to: fileURL)
                observer.onNext(fileURL)
                observer.onCompleted()
            }
            catch {
                Log.some(error)
                observer.onError(error)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    /**
     */
    func removeFile(at url: URL) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.fileManager.removeItem(at: url)
                observer.onNext(())
                observer.onCompleted()
            }
            catch {
                Log.some(error)
                observer.onError(error)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
