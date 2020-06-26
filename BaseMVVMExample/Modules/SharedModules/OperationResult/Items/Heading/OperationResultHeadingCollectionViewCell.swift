//
//  OperationResultHeadingCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OperationResultHeadingCollectionViewCell: UICollectionViewCell {
    
    private let headingView = OperationResultHeadingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headingView)
        headingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension OperationResultHeadingCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: OperationResultHeadingViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return OperationResultHeadingView.estimatedSize(for: item, superviewSize: collectionViewSize)
    }
    
    func configure(item: OperationResultHeadingViewModelProtocol) {
        headingView.configure(with: item)
    }
}
