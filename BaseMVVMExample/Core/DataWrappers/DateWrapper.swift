//
//  DateWrapper.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol DateRepresentable {
    var date: Date? { get }
}

///
protocol DateStringConvertible: StringConvertible, DateRepresentable {
    var formatter: DateFormatter { get }
}

///
class DateWrapper: DateStringConvertible {
    var date: Date?
    var formatter: DateFormatter
    var asString: String {
        guard let date = date else { return "" }
        return formatter.string(from: date)
    }
    
    init(date: Date?, formatter: DateFormatter) {
        self.date = date
        self.formatter = formatter
    }
}
