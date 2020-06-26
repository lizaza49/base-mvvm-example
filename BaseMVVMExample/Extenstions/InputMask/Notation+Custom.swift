//
//  Notation+Custom.swift
//  BaseMVVMExample
//
//  Created by Admin on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import InputMask

///
extension Notation {
    
    // Birth certificate prefix
    static let birthCertificatePrefixRequired = Notation(character: "V", characterSet: CharacterSet(charactersIn: "IVXivx"), isOptional: false)
    static let birthCertificatePrefixOptional = Notation(character: "v", characterSet: CharacterSet(charactersIn: "IVXivx"), isOptional: true)
    
    // Cyrillic letters
    static let cyrillicRequired = Notation(
        character: "Б",
        characterSet: CharacterSet(charactersIn: (Unicode.Scalar(1040)! ..< Unicode.Scalar(1104)!)),
        isOptional: false)
    static let cyrillicOptional = Notation(
        character: "б",
        characterSet: CharacterSet(charactersIn: (Unicode.Scalar(1040)! ..< Unicode.Scalar(1104)!)),
        isOptional: true)
}
