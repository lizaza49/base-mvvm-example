//
//  RemoteItemPickerCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class RemoteItemPickerCollectionViewCell: UICollectionViewCell {
    
    private let radioButton = RadioButtonControl()
    private let label = UILabel()
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            updateSelectionState(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        radioButton.isUserInteractionEnabled = false
        addSubview(radioButton)
        radioButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.sideInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(RadioButtonControl.UIConstants.containerSize)
        }
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.labelLeftInset)
            make.right.equalToSuperview().inset(UIConstants.labelRightInset)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    private static func attributedText(with item: RemoteItemPickerCellViewModelProtocol) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: item.text)
        attributedText.apply(textStyle: UIConstants.textStyle)
        if let matchToHighlight = item.matchToHighlight {
            attributedText.apply(textStyle: UIConstants.highlightedStyle, ranges: [matchToHighlight])
        }
        return attributedText
    }
    
    /**
     */
    private func updateSelectionState(_ isSelected: Bool) {
        radioButton.isSelected = isSelected
    }
}

///
extension RemoteItemPickerCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: RemoteItemPickerCellViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        let text = attributedText(with: item)
        let maxLabelSize = collectionViewSize.width - UIConstants.labelLeftInset - UIConstants.labelRightInset
        var height: CGFloat = UIConstants.labelVerticalMargin * 2
        height += text.boundingRect(with: CGSize(width: maxLabelSize, height: 0), options: [], context: nil).height
        return CGSize(width: collectionViewSize.width, height: max(UIConstants.minHeight, height))
    }
    
    func configure(item: RemoteItemPickerCellViewModelProtocol) {
        label.attributedText = RemoteItemPickerCollectionViewCell.attributedText(with: item)
    }
}

///
extension RemoteItemPickerCollectionViewCell {
    
    ///
    struct UIConstants {
        static let minHeight: CGFloat = 52
        static let sideInset: CGFloat = 16
        static let labelLeftInset: CGFloat = 56
        static var labelRightInset: CGFloat { return sideInset }
        static let labelVerticalMargin: CGFloat = 17
        static let textStyle = TextStyle(Color.black, Font.regular15, .left)
        static let highlightedStyle = TextStyle(Color.black, Font.bold15, .left)
    }
}
