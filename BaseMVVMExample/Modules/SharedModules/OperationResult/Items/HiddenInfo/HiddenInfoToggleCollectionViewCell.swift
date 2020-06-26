//
//  HiddenInfoToggleCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 25/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
final class HiddenInfoToggleCollectionViewCell: UICollectionViewCell {
    
    private let label = UILabel()
    private let arrow = UIImageView()
    private var reusableDisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.apply(textStyle: UIConstants.textStyle)
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-UIConstants.arrowSize.width/2)
            make.width.equalTo(0)
        }
        
        arrow.image = Asset.Common.commonArrowUp.image
        arrow.contentMode = .scaleAspectFill
        addSubview(arrow)
        arrow.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right)
            make.centerY.equalToSuperview().offset(UIConstants.arrowMidYOffset)
            make.size.equalTo(UIConstants.arrowSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateExpansionState(isExpanded: Bool, animated: Bool) {
        let animatableUpdates = {
            self.arrow.transform = isExpanded ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: animatableUpdates)
        }
        else {
            animatableUpdates()
        }
    }
}

///
extension HiddenInfoToggleCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: HiddenInfoToggleViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        let maxLabelWidth: CGFloat = collectionViewSize.width - UIConstants.sideInsets * 2 - UIConstants.arrowSize.width
        var height: CGFloat = UIConstants.sideInsets * 2
        height += item.title.size(using: UIConstants.textStyle.font, boundingWidth: maxLabelWidth).height
        return CGSize(width: collectionViewSize.width, height: max(UIConstants.minHeight, height))
    }
    
    func configure(item: HiddenInfoToggleViewModelProtocol) {
        reusableDisposeBag = DisposeBag()
        label.text = item.title
        let maxLabelWidth: CGFloat = bounds.width - UIConstants.sideInsets * 2 - UIConstants.arrowSize.width
        let size = label.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
        label.snp.updateConstraints { (make) in
            make.width.equalTo(size.width)
        }
        
        item.isExpanded.asDriver(onErrorJustReturn: false)
            .drive(onNext: {
                self.updateExpansionState(isExpanded: $0, animated: false)
            })
            .disposed(by: reusableDisposeBag)
    }
}

///
extension HiddenInfoToggleCollectionViewCell {
    ///
    struct UIConstants {
        static let textStyle = TextStyle(Color.black, Font.regular15, .left)
        static let minHeight: CGFloat = 52
        static let arrowSize = CGSize(width: 24, height: 24)
        static let arrowMidYOffset: CGFloat = 1
        static let sideInsets: CGFloat = 16
    }
}
