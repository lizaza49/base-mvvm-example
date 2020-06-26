//
//  FormInputViewToolbar.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class FormInputViewToolbar: UIToolbar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        barStyle = .default
        isTranslucent = true
        tintColor = Color.cherry
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
