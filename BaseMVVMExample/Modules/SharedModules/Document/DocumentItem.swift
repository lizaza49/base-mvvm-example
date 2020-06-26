//
//  DocumentItem.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import QuickLook

///
class DocumentItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    
    init(itemURL: URL?) {
        self.previewItemURL = itemURL
    }
}
