//
//  PromoBannerCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 13/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import SDWebImage
import RxSwift

fileprivate typealias ContentOffsetUpdate = (prev: Float, next: Float)

///
final class PromoBannerCollectionViewCell: UICollectionViewCell {
    
    private let backgroundImageView = UIImageView()
    private let middleImageView = UIImageView()
    private let foregroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let offerLabel = UILabel()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        backgroundImageView.alpha = 0
        backgroundImageView.contentMode = .scaleAspectFill
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(snp.width).multipliedBy(1/UIConstants.defaultAspectRatio)
        }
        
        middleImageView.alpha = 0
        middleImageView.contentMode = .scaleAspectFill
        addSubview(middleImageView)
        middleImageView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(UIConstants.middleImageBottomOffsetRange.upperBound)
            make.height.equalTo(snp.width).multipliedBy(1/UIConstants.defaultAspectRatio)
        }
        
        foregroundImageView.alpha = 0
        foregroundImageView.contentMode = .scaleAspectFill
        addSubview(foregroundImageView)
        foregroundImageView.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(snp.width).multipliedBy(1/UIConstants.defaultAspectRatio)
        }
        
        offerLabel.apply(textStyle: UIConstants.offerTextStyle())
        addSubview(offerLabel)
        offerLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(UIConstants.adjustHeight(175))
            make.right.equalToSuperview().inset(20)
        }
        
        titleLabel.apply(textStyle: UIConstants.titleTextStyle())
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(offerLabel.snp.bottom).offset(-8)
            make.right.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        updateAnimation()
        disposeBag = DisposeBag()
    }
    
    /**
     */
    private func updateImage(with imageUrl: URL?, for imageView: UIImageView) {
        SDWebImageManager.shared()
            .loadImage(with: imageUrl, options: [], progress: nil) { [weak imageView] (image, _, _, _, _, url) in
                guard let imageView = imageView, imageUrl == url else { return }
                imageView.fadeIn()
                imageView.image = image
        }
    }
    
    /**
     */
    private func adjustImages(for contentOffsetUpdate: ContentOffsetUpdate) {
        let targetOffsetRange = (-UIConstants.cellMinMaxHeightDiff ... 0)
        let prevOffset = CGFloat(contentOffsetUpdate.prev)
        let nextOffset = CGFloat(contentOffsetUpdate.next)
        
        let nextOffsetFitsTargetRange = targetOffsetRange ~= nextOffset
        let nextOffsetDidCrossLowerBound = (prevOffset + UIConstants.cellMinMaxHeightDiff).sign != (nextOffset + UIConstants.cellMinMaxHeightDiff).sign
        let nextOffsetDidCrossUpperBound = prevOffset.sign != nextOffset.sign
        guard nextOffsetFitsTargetRange || nextOffsetDidCrossLowerBound || nextOffsetDidCrossUpperBound else {
            return
        }
        // Fit offset to the range
        let adjustedOffset = max(min(nextOffset, targetOffsetRange.upperBound), targetOffsetRange.lowerBound)
        let middleImageBottomOffsetDiff = UIConstants.middleImageBottomOffsetRange.upperBound - UIConstants.middleImageBottomOffsetRange.lowerBound
        let middleImageBottomOffset = UIConstants.middleImageBottomOffsetRange.lowerBound + middleImageBottomOffsetDiff * (1 - abs(adjustedOffset / UIConstants.cellMinMaxHeightDiff))
        middleImageView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(middleImageBottomOffset)
        }
        contentView.layoutIfNeeded()
    }
    
    /**
     */
    private func updateAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0.3, options: [.beginFromCurrentState, .repeat, .autoreverse, .curveEaseInOut], animations: {
            self.foregroundImageView.transform = CGAffineTransform(translationX: 0, y: -10)
        }, completion: { finished in
            self.foregroundImageView.transform = .identity
            if finished { self.updateAnimation() }
        })
    }
}

///
extension PromoBannerCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: PromoBannerViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: item == nil ? 0 : UIConstants.cellHeight)
    }
    
    func configure(item: PromoBannerViewModelProtocol) {
        backgroundColor = Color.make(hex: item.backgroundColorHex) ?? UIConstants.defaultBackgroundColor
        titleLabel.text = item.title
        offerLabel.text = item.offer
        updateImage(with: item.backgroundImageUrl, for: backgroundImageView)
        updateImage(with: item.middleImageUrl, for: middleImageView)
        updateImage(with: item.foregroundImageUrl, for: foregroundImageView)
        item.scrollContentOffsetY.asObservable()
            .takeUntil(rx.deallocated)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .scan(ContentOffsetUpdate(prev: 0, next: 0), accumulator: {
                return ($0.next, $1)
            })
            .subscribe(onNext: adjustImages)
            .disposed(by: disposeBag)
    }
}

///
extension PromoBannerCollectionViewCell {
    struct UIConstants {
        private static let defaultCellHeight: CGFloat = 284.0
        
        static func adjustHeight(_ height: CGFloat) -> CGFloat {
            return cellHeight / defaultCellHeight * height
        }
        static let cellHeight: CGFloat = UIScreen.main.bounds.width / defaultAspectRatio
        static let cellMinMaxHeightDiff: CGFloat = 50
        static let maxCellHeight: CGFloat = cellHeight + cellMinMaxHeightDiff
        static let defaultAspectRatio: CGFloat = 375.0 / defaultCellHeight
        static let middleImageBottomOffsetRange: ClosedRange<CGFloat> = (4 ... 43)
        static let defaultBackgroundColor = Color.dummyView
        static func titleTextStyle(colorHex: String? = nil) -> TextStyle {
            let color = Color.make(hex: colorHex ?? "") ?? Color.mustard
            return TextStyle(color, Font.bold32, .right, 1)
        }
        static func offerTextStyle(colorHex: String? = nil) -> TextStyle {
            let color = Color.make(hex: colorHex ?? "") ?? Color.mustard
            return TextStyle(color, Font.thin58Italic, .right, 1)
        }
    }
}
