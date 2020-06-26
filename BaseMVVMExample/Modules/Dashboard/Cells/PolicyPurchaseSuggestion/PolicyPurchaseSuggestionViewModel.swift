//
//  PolicyPurchaseSuggestionViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 27/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol DashboardPolicyPurchaseSuggestionViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var purchaseButtonTitle: String { get }
    var backgroundImageUrl: URL? { get }
    var tapAction: PublishSubject<Void> { get }
    var disposeBag: DisposeBag { get }
}

///
extension Dashboard.Policies.PurchaseSuggestion {
    
    typealias ViewModelProtocol = DashboardPolicyPurchaseSuggestionViewModelProtocol
    private typealias Texts = L10n.Common.Dashboard.Policies.PurchaseSuggestion
    
    ///
    class ViewModel: DashboardPolicyPurchaseSuggestionViewModelProtocol {
        let title: String
        let subtitle: String
        let purchaseButtonTitle: String
        let backgroundImageUrl: URL?
        let tapAction = PublishSubject<Void>()
        let disposeBag = DisposeBag()
        
        init(title: String,
             subtitle: String,
             purchaseButtonTitle: String,
             backgroundImageUrl: URL?) {
            self.title = title
            self.subtitle = subtitle
            self.purchaseButtonTitle = purchaseButtonTitle
            self.backgroundImageUrl = backgroundImageUrl
        }
        
        static var `default`: ViewModelProtocol = {
            return ViewModel(
                title: Texts.title,
                subtitle: Texts.subtitle,
                purchaseButtonTitle: Texts.purchaseButton,
                backgroundImageUrl: nil)
        }()
        
        static func make(backgroundImageUrl: URL?) -> ViewModelProtocol {
            return ViewModel(title: Texts.title, 
                             subtitle: Texts.subtitle,
                             purchaseButtonTitle: Texts.purchaseButton,
                             backgroundImageUrl: backgroundImageUrl)
        }
    }
}
