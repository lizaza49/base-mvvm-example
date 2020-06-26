//
//  FormInputRichTextViewCell.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 06/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

class FormInputRichTextViewCell: UICollectionViewCell {
	private let formInputRichTextView = FormInputRichTextView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(formInputRichTextView)
		formInputRichTextView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension FormInputRichTextViewCell: ConfigurableCollectionItem {
	static func estimatedSize(item: FormInputRichTextViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		return FormInputRichTextView.estimatedSize(for: item, superviewSize: collectionViewSize)
	}
	
	func configure(item: FormInputRichTextViewModelProtocol) {
		formInputRichTextView.configure(with: item)
	}
}
