//
//  PersonalOfferViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol PersonalOfferViewModelProtocol {
    var externalURL: URL? { get }
    var imageURL: URL? { get }
    
    // Texts
    var title: String { get }
    var subtitle: String { get }
    var offer: String { get }
    var tag: String { get }
    
    // Colors
    var backgroundColorHex: String { get }
    var tagColor: String { get }
    
    var hasShadow: Bool { get }
    
    var tapEvent: PublishSubject<PersonalOfferViewModelProtocol> { get }
}

///
class PersonalOfferViewModel: PersonalOfferViewModelProtocol {
    let externalURL: URL?
    let imageURL: URL?
    
    // Texts
    let title: String
    let subtitle: String
    let offer: String
    let tag: String
    
    // Colors
    let backgroundColorHex: String
    let tagColor: String
    
    let hasShadow: Bool
    
    // Actions
    let tapEvent: PublishSubject<PersonalOfferViewModelProtocol> = PublishSubject()
    
    /**
     */
    init(with model: PersonalOffer) {
        externalURL = model.externalURL
        imageURL = model.imageURL
        title = model.title
        subtitle = model.subtitle
        offer = model.offer
        tag = model.tag
        backgroundColorHex = model.backgroundСolor
        tagColor = model.tagColor
        hasShadow = false
    }
    
    /**
     For dummy view
     */
    private init(externalURL: URL? = nil, imageURL: URL? = nil, title: String = "", subtitle: String = "", offer: String = "", tag: String = "", backgroundColorHex: String = "", tagColor: String = "", hasShadow: Bool = false) {
        self.externalURL = externalURL
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.offer = offer
        self.tag = tag
        self.backgroundColorHex = backgroundColorHex
        self.tagColor = tagColor
        self.hasShadow = hasShadow
    }
    
    static let dummy: PersonalOfferViewModelProtocol = PersonalOfferViewModel(backgroundColorHex: "#ffffff", hasShadow: true)
}
