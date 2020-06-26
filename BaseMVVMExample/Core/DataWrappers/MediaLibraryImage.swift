//
//  MediaLibraryImage.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol MediaLibraryImageProtocol: StringConvertible {
    var name: String { get }
    var data: Data { get }
}

///
extension MediaLibraryImageProtocol {
    var asString: String { return name }
}

///
class MediaLibraryImage: MediaLibraryImageProtocol {
    let name: String
    let data: Data
    
    /**
     */
    init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}
