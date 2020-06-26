//
//  PersonalOffersListCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
final class PersonalOffersListCollectionViewCell: UICollectionViewCell {
    
    private lazy var collectionView: UICollectionView = {
        let layout = PersonalOffersListCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = UIConstants.lineSpacing
        return UICollectionView(frame: bounds, collectionViewLayout: layout)
    }()
    private var director: CollectionDirector!
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.contentInset = UIConstants.contentInsets
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        director = CollectionDirector(colletionView: collectionView)
        director.shouldUseAutomaticViewRegistration = true
    }
    
    /**
     */
    private func configureCollectionView(with viewModel: PersonalOffersListViewModelProtocol) {
        collectionView.setContentOffset(CGPoint(x: CGFloat(viewModel.contentOffset) - UIConstants.contentInsets.left, y: 0), animated: false)
        let shoudDisplayDummyCells = viewModel.offersViewModels.value.isEmpty
        collectionView.isUserInteractionEnabled = !shoudDisplayDummyCells
        director.clear()
        
        let section = CollectionSection()
        section.lineSpacing = UIConstants.lineSpacing
        let offersViewModels = shoudDisplayDummyCells ?
            makeDummyOffersViewModels() :
            viewModel.offersViewModels.value
        section.append(items: offersViewModels.map(makeItem))
        director += section
        
        director.reload()
    }
    
    /**
     */
    private func makeItem(with viewModel: PersonalOfferViewModelProtocol) -> AbstractCollectionItem {
        let item = CollectionItem<PersonalOfferCollectionViewCell>(item: viewModel)
        item.onSelect = { _ in
            viewModel.tapEvent.on(Event.next(viewModel))
        }
        return item
    }
    
    /**
     */
    private func makeDummyOffersViewModels() -> [PersonalOfferViewModelProtocol] {
        return (0 ..< 3).map { _ in PersonalOfferViewModel.dummy }
    }
}

///
extension PersonalOffersListCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: PersonalOffersListViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 267)
    }
    
    func configure(item: PersonalOffersListViewModelProtocol) {
        configureCollectionView(with: item)
    }
}

///
extension PersonalOffersListCollectionViewCell {
    struct UIConstants {
        static let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let lineSpacing: CGFloat = 12
    }
}
