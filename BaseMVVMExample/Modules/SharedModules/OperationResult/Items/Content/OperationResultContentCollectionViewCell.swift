//
//  OperationResultContentCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OperationResultContentCollectionViewCell: UICollectionViewCell {
    
    private let contentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentLabel.apply(textStyle: UIConstants.contentStyle)
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension OperationResultContentCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: String?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return CGSize(
            width: collectionViewSize.width,
            height: item.size(using: UIConstants.contentStyle.font, boundingWidth: collectionViewSize.width - UIConstants.sideInset * 2).height + 2)
    }
    
    func configure(item: String) {
        contentLabel.text = item
    }
}

///
extension OperationResultContentCollectionViewCell {
    struct UIConstants {
        static let contentStyle = TextStyle(Color.noteGray, Font.regular14, .center)
        static let sideInset: CGFloat = 28
    }
}
