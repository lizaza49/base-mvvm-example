//
//  DateFormatter+Formats.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
extension DateFormatter {
    
    /// dd.MM.yyyy
    static let formInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    /// dd.MM.yyyy
    static let formTimeInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    /// yyyy-MM-dd'T'HH:mm:ssZ
    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    /// dd MMMM yyyy
    static let policyDueDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    /// dd.MM.yyyy HH:mm:ss
    static let policyTemp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter
    }()
    
    /// dd.MM.yyyy, HH:mm
    static let commaSeparatedDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter
    }()
}
