//
//  FormStepHeadingCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 20/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class FormStepHeadingCollectionViewCell: UICollectionViewCell {
    
    private let headingView = FormStepHeadingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.white
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
extension FormStepHeadingCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: FormStepHeadingViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return FormStepHeadingView.estimatedSize(for: item, superviewSize: collectionViewSize)
    }
    
    func configure(item: FormStepHeadingViewModelProtocol) {
        headingView.configure(with: item)
    }
}
