//
//  RemoteItemPickerCellViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol RemoteItemPickerCellViewModelProtocol {
    var text: String { get }
    var matchToHighlight: NSRange? { get }
}

///
class RemoteItemPickerCellViewModel: RemoteItemPickerCellViewModelProtocol {
    var text: String
    var matchToHighlight: NSRange?
    
    init(text: String, query: String) {
        self.text = text
        let textToFindMatches = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let regex = try NSRegularExpression(pattern: query.lowercased(), options: [])
            let wholeTextRange = NSRange(location: 0, length: textToFindMatches.count)
            let matches = regex.matches(in: textToFindMatches, options: [], range: wholeTextRange)
            matchToHighlight = matches.first?.range
        }
        catch {
            matchToHighlight = nil
        }
    }
}
