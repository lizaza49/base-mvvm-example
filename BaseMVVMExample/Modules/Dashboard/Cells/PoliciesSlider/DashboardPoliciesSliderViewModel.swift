//
//  DashboardPoliciesSliderVIewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 25/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol DashboardPoliciesSliderViewModelProtocol: class {
    
    var policies: Variable<[PolicyItemViewModelProtocol]> { get }
    var purchaseSuggestion: Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol? { get }
    var selectedItemIndex: Int? { get }
    var tapAction: PublishSubject<PolicyItemViewModelProtocol> { get }
}

extension Dashboard.Policies.Slider {
    typealias ViewModelProtocol = DashboardPoliciesSliderViewModelProtocol
    
    ///
    class ViewModel: ViewModelProtocol {
        
        let policies: Variable<[PolicyItemViewModelProtocol]>
        let purchaseSuggestion: Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol?
        let selectedItemIndex: Int?
        let tapAction: PublishSubject<PolicyItemViewModelProtocol>
        
        let disposeBag = DisposeBag()
        
        init(policies: [PolicyItemViewModelProtocol],
             selectedItemIndex: Int? = nil,
             purchaseSuggestion: Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol? = nil) {
            self.policies = Variable(policies)
            self.selectedItemIndex = selectedItemIndex
            self.purchaseSuggestion = purchaseSuggestion
            tapAction = PublishSubject()
        }
        
        static let dummy: ViewModelProtocol = ViewModel(policies: [])
    }
}
