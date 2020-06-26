//
//  DashboardSectionHeader.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
enum DashboardSectionHeader: Int, CollectionSectionTypeProtocol {
    case myPolicies = 0, personalOffers, insuranceCases, news
    
    var title: String {
        typealias Titles = L10n.Common.Dashboard.Section.Title
        switch self {
        case .myPolicies:
            return Titles.myPolicies
        case .personalOffers:
            return Titles.personalOffers
        case .insuranceCases:
            return Titles.insuranceCases
        case .news:
            return Titles.news
        }
    }
    
    static var all: [CollectionSectionTypeProtocol] {
        return (0 ..< 4).compactMap { DashboardSectionHeader(rawValue: $0) }
    }
}
