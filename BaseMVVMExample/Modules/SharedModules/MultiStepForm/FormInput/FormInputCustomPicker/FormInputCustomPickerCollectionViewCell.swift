//
//  FormInputCustomPickerCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import IVCollectionKit
import UIKit

///
final class FormInputCustomPickerCollectionViewCell: UICollectionViewCell {
    
    private let pickerView = FormInputCustomPickerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension FormInputCustomPickerCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: FormInputCustomPickerViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return FormInputCustomPickerView.estimatedSize(for: item, superviewSize: collectionViewSize)
    }
    
    func configure(item: FormInputCustomPickerViewModelProtocol) {
        pickerView.configure(with: item)
    }
}
