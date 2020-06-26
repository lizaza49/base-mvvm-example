//
//  HTTPClient.swift
//  BaseMVVMExample
//
//  Created by Admin on 13/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

///
class EmptyResult: Codable {}

///
class HTTPClient: NSObject {
    
    private let jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder = .defaultDateData) {
        self.jsonDecoder = jsonDecoder
    }
    
    /**
     */
    private func jsonResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
    
    /**
     */
    private func makeMoyaProvider<TargetType: BaseApiNetworkRouterProtocol>() -> MoyaProvider<TargetType> {
        var plugins: [PluginType] = []
        #if DEBUG
        plugins = [NetworkLoggerPlugin(verbose: false,
                                      responseDataFormatter: jsonResponseDataFormatter)]
        #endif
        return MoyaProvider<TargetType>(plugins: plugins)
    }
    
    /**
     */
    func request<ResponseData: Codable, TargetType: BaseApiNetworkRouterProtocol>(token: TargetType) -> Observable<ResponseData> {
        return request(provider: makeMoyaProvider(), token: token)
    }
    
    /**
     */
    func request<ResponseData: Codable, TargetType: BaseApiNetworkRouterProtocol>(provider: MoyaProvider<TargetType>, token: TargetType) -> Observable<ResponseData> {
        return Observable<ResponseData>.create { (observer) -> Disposable in
            return provider.rx.request(token)
                .subscribeOn(ConcurrentMainScheduler.instance)
                .filterSuccessfulStatusCodes()
                .map(ResponseData.self, using: self.jsonDecoder, failsOnEmptyData: false)
                .asObservable()
                .takeUntil(self.rx.deallocated)
                .subscribe(onNext: { response in
                    observer.onNext(response)
                    observer.onCompleted()
                }, onError: { error in
                    if let moyaError = error as? MoyaError {
                        observer.onError(self.map(moyaError: moyaError))
                    }
                    else {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                })
        }
    }
    
    /**
     */
    func plainRequest<TargetType: BaseApiNetworkRouterProtocol>(provider: MoyaProvider<TargetType>? = nil, token: TargetType) -> Observable<Void> {
        let provider = provider ?? makeMoyaProvider()
        return Observable<Void>.create { (observer) -> Disposable in
            return provider.rx.request(token)
                .subscribeOn(ConcurrentMainScheduler.instance)
                .asObservable()
                .takeUntil(self.rx.deallocated)
                .subscribe(onNext: { response in
                    if let error = self.getError(from: response) {
                        observer.onError(error)
                    }
                    else {
                        observer.onNext(())
                    }
                    observer.onCompleted()
                }, onError: { error in
                    if let moyaError = error as? MoyaError {
                        observer.onError(self.map(moyaError: moyaError))
                    }
                    else {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                })
        }
    }
    
    /**
     */
    func download<TargetType: BaseApiNetworkRouterProtocol>(token: TargetType) -> Observable<Data> {
        let provider: MoyaProvider<TargetType> = makeMoyaProvider()
        return Observable<Data>.create { (observer) -> Disposable in
            return provider.rx.request(token)
                .subscribeOn(ConcurrentMainScheduler.instance)
                .asObservable()
                .takeUntil(self.rx.deallocated)
                .map { $0.data }
                .subscribe(
                    onNext: {
                        observer.onNext($0)
                        observer.onCompleted()
                    },
                    onError: { error in
                        if let moyaError = error as? MoyaError {
                            observer.onError(self.map(moyaError: moyaError))
                        }
                        else {
                            observer.onError(error)
                        }
                })
        }
    }
    
    /**
     */
    private func map(moyaError: MoyaError) -> BaseError {
        var error: BaseError?
        switch moyaError {
        case .objectMapping(let error, _):
            Log.some(error)
            error = .parsingError(code: HTTPStatusCode(rawValue: moyaError.response?.statusCode ?? -1) ?? .undefined)
            break
        case .statusCode(let response):
            error = getError(from: response)
            break
        default: break
        }
        return error ?? .undefined
    }
    
    /**
     */
    private func getError(from response: Response) -> BaseError? {
        switch response.statusCode {
        case 200 ..< 300:
            return nil
        case 400 ..< 500:
            do {
                let apiError = try JSONDecoder().decode(ApiErrorResponse.self, from: response.data)
                return BaseError.apiError(apiError)
            }
            catch {
                Log.some(error)
                return .undefined
            }
        case 500 ..< 600:
            return .serverError
        default:
            return .undefined
        }
    }
}
