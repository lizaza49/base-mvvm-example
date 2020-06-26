//
//  ModalPickerViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
final class ModalPickerViewController: BaseViewController {

    ///
    var viewModel: ModalPickerViewModelProtocol!
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIConstants.dimmingColor
        setupViews()
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupViews() {
        
    }
}

extension ModalPickerViewController {
    
    struct UIConstants {
        static let dimmingColor = Color.black.withAlphaComponent(0.3)
    }
}
