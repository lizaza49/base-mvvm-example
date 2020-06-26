//
//  PersonalOffersListCollectionViewLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 15/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class PersonalOffersListCollectionViewLayout: HorizontalSnapCollectionViewLayout {
    
    override var itemWidth: CGFloat? {
        return PersonalOfferCollectionViewCell.UIConstants.cellWidth
    }
}
