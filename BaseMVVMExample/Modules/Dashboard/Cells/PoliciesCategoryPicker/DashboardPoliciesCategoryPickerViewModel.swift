//
//  DashboardPoliciesCategoryPickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol DashboardPoliciesCategoryPickerViewModelProtocol {
    var pickedCategory: Variable<PolicyCategoryViewModelProtocol?> { get }
    var categories: [PolicyCategoryViewModelProtocol] { get }
    
    var disposeBag: DisposeBag { get }
}

extension DashboardPoliciesCategoryPickerViewModelProtocol {
    var selectedItemIndex: Int? {
        guard let pickedCategory = pickedCategory.value else { return nil }
        return categories.firstIndex(where: { $0.id == pickedCategory.id })
    }
}

///
class DashboardPoliciesCategoryPickerViewModel: DashboardPoliciesCategoryPickerViewModelProtocol {
    let pickedCategory: Variable<PolicyCategoryViewModelProtocol?>
    let categories: [PolicyCategoryViewModelProtocol]
    let disposeBag = DisposeBag()
    
    init(categories: [PolicyCategoryViewModelProtocol], pickedCategory: PolicyCategoryViewModelProtocol? = nil) {
        self.categories = categories
        self.pickedCategory = Variable(pickedCategory)
    }
    
    static let dummy = DashboardPoliciesCategoryPickerViewModel(categories: [])
}
