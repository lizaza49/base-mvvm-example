//
//  ConfirmationCodeInputViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol ConfirmationCodeInputViewModelProtocol {
    var code: Variable<[Int]> { get }
    var requiredLength: Int { get }
    var isFulfilled: Bool { get }
    var resetSignal: PublishSubject<Void> { get }
    
    func dropLast()
    func append(string: String) -> [Int]
    
    var disposeBag: DisposeBag { get }
}

///
struct ConfirmationCodeInputViewModel: ConfirmationCodeInputViewModelProtocol {
    let code: Variable<[Int]>
    let requiredLength: Int
    let resetSignal = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    var isFulfilled: Bool {
        return code.value.count == requiredLength
    }
    
    init(code: [Int], requiredLength: Int) {
        self.code = Variable(code)
        self.requiredLength = requiredLength
    }
    
    func dropLast() {
        code.value = Array(code.value.dropLast())
    }
    
    func append(string: String) -> [Int] {
        guard requiredLength > code.value.count else { return [] }
        var digits = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
            .compactMap { Int(String($0)) }
        if digits.count > requiredLength - code.value.count {
            digits = Array(digits[0 ..< requiredLength - code.value.count])
        }
        code.value.append(contentsOf: digits)
        return digits
    }
}
