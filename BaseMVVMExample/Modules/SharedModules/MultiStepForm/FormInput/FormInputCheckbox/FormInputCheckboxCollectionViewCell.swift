//
//  FormInputCheckboxCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class FormInputCheckboxCollectionViewCell: UICollectionViewCell {
    
    private let formInputCheckboxView = FormInputCheckboxView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(formInputCheckboxView)
        formInputCheckboxView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension FormInputCheckboxCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: FormInputCheckboxViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return FormInputCheckboxView.estimatedSize(for: item, superviewSize: collectionViewSize)
    }
    
    func configure(item: FormInputCheckboxViewModelProtocol) {
        formInputCheckboxView.configure(with: item)
    }
}
