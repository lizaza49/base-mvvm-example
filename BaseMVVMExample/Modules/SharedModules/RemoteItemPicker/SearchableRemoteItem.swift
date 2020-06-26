//
//  SearchableRemoteItem.swift
//  BaseMVVMExample
//
//  Created by Admin on 18/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol SearchableRemoteItemProtocol: class, Codable {
    var id: Int { get }
    var name: String { get }
}

/// Used for items with no special requirements to be requested.
/// E.g. Settlements are requested with no params and thus are plain.
/// But Streets are requested using a target settlement id and thus they are not plain
protocol PlainSearchableRemoteItemProtocol: SearchableRemoteItemProtocol {}
