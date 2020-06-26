//
//  FormInputMaskDescriptor.swift
//  BaseMVVMExample
//
//  Created by Admin on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import InputMask

///
class FormInputMaskDescriptor {
    var format: String
    var notations: [Notation]
    var affinity: Affinity?
    
    init(format: String, notations: [Notation] = [], affinity: Affinity? = nil) {
        self.format = format
        self.notations = notations
        self.affinity = affinity
    }
    
    static let zipCode = FormInputMaskDescriptor(format: "[000000]")
    static let policyFullNumber = FormInputMaskDescriptor(format: "[AAA] [0000000000]")
    static let driverLicence = FormInputMaskDescriptor(format: "[00__] [000000]")
    static let enginePower = FormInputMaskDescriptor(
        format: "[09999]",
        affinity: Affinity(calculationStrategy: .prefix, formats: ["[09999].[0]"]))
    static let vehicleVin = FormInputMaskDescriptor(
        format: "[VVVVVVVVVVVVVVVVV]",
        notations: [Notation(character: "V",
                             characterSet: CharacterSet.latinUppercased.removing(charsIn: "QOI").union(.digits),
                             isOptional: false)])
    static let vehicleBody = FormInputMaskDescriptor(
        format: "[Bbbbbbbbbbbbbbbbbbbbbbbb]",
        notations: [Notation(character: "B",
                             characterSet: CharacterSet.latinUppercased.union(.digits),
                             isOptional: false),
                    Notation(character: "b",
                             characterSet: CharacterSet.latinUppercased.union(.digits).union(CharacterSet(charactersIn: "-")),
                             isOptional: true)])
    static let vehicleRegistrationNumber = FormInputMaskDescriptor(
        format: "[w000ww009]",
        notations: [
            Notation(character: "w",
                     characterSet: CharacterSet.vehicleRegistrationNumberLetters.union(.digits),
                     isOptional: true)
        ])
    
    ///
    struct Affinity {
        var calculationStrategy: AffinityCalculationStrategy
        var formats: [String]
    }
}
