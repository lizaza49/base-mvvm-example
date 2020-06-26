//
//  PromoBannerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 13/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol PromoBannerViewModelProtocol {
    var backgroundColorHex: String { get }
    var foregroundColorHex: String { get }
    var backgroundImageUrl: URL? { get }
    var middleImageUrl: URL? { get }
    var foregroundImageUrl: URL? { get }
    var title: String { get }
    var offer: String { get }
    
    var scrollContentOffsetY: Variable<Float> { get }
}

///
final class PromoBannerViewModel: PromoBannerViewModelProtocol {
    let backgroundColorHex: String
    let foregroundColorHex: String
    let backgroundImageUrl: URL?
    let middleImageUrl: URL?
    let foregroundImageUrl: URL?
    let title: String
    let offer: String
    let scrollContentOffsetY: Variable<Float>
    
    /**
     */
    init(with banner: PromoBanner, scrollContentOffsetY: Float = 0) {
        self.backgroundColorHex = banner.backgroundColor
        self.foregroundColorHex = banner.titleColor
        self.backgroundImageUrl = banner.backImageURL
        self.middleImageUrl = banner.middleImageURL
        self.foregroundImageUrl = banner.frontImageURL
        self.title = banner.title2
        self.offer = banner.title1
        self.scrollContentOffsetY = Variable(scrollContentOffsetY)
    }
    
    /**
     For dummy view
     */
    private init(backgroundColorHex: String, foregroundColorHex: String = "", backgroundImageUrl: URL? = nil, middleImageUrl: URL? = nil, foregroundImageUrl: URL? = nil, title: String = "", offer: String = "", scrollContentOffsetY: Float = 0) {
        self.backgroundColorHex = backgroundColorHex
        self.foregroundColorHex = foregroundColorHex
        self.backgroundImageUrl = backgroundImageUrl
        self.middleImageUrl = middleImageUrl
        self.foregroundImageUrl = foregroundImageUrl
        self.title = title
        self.offer = offer
        self.scrollContentOffsetY = Variable(scrollContentOffsetY)
    }
    
    ///
    static let dummy: PromoBannerViewModelProtocol = PromoBannerViewModel(backgroundColorHex: UIConstants.dummyColorHex)
}

///
extension PromoBannerViewModel {
    struct UIConstants {
        static let dummyColorHex = "#292929"
    }
}
