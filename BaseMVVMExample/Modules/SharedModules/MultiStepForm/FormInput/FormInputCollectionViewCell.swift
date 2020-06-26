//
//  FormInputCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 20/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
protocol FormInputViewProtocol {
    var isEditing: Bool { get }
}

///
final class FormInputCollectionViewCell<InputData: StringConvertible>: UICollectionViewCell, FormInputViewProtocol {
    
    ///
    private let formInputView = FormInputView<FormInputViewModel<InputData>>()
    var isEditing: Bool {
        return formInputView.isEditing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(formInputView)
        formInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension FormInputCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: FormInputViewModel<InputData>?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        return FormInputView<FormInputViewModel<InputData>>.estimatedSize(for: item, superviewSize: collectionViewSize)
    }
    
    func configure(item: FormInputViewModel<InputData>) {
        formInputView.configure(with: item)
    }
}
