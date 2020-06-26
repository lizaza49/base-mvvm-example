//
//  PersonalOffersListViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol PersonalOffersListViewModelProtocol {
    var offersViewModels: Variable<[PersonalOfferViewModelProtocol]> { get }
    var contentOffset: Float { get }
}

///
class PersonalOffersListViewModel: PersonalOffersListViewModelProtocol {
    let offersViewModels: Variable<[PersonalOfferViewModelProtocol]>
    let contentOffset: Float
    
    /**
     */
    init(offersViewModels: [PersonalOfferViewModelProtocol],
         contentOffset: Float = 0) {
        self.offersViewModels = Variable(offersViewModels)
        self.contentOffset = contentOffset
    }
    
    ///
    static let dummy: PersonalOffersListViewModelProtocol = PersonalOffersListViewModel(offersViewModels: [])
}
