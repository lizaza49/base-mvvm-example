//
//  CharacterSet+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
extension CharacterSet {
    private static let latinAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static let latinUppercased = CharacterSet(charactersIn: latinAlphabet)
    static let latinLowercased = CharacterSet(charactersIn: latinAlphabet.lowercased())
    static let digits = CharacterSet(charactersIn: "0123456789")
    static let vehicleRegistrationNumberLetters = CharacterSet(charactersIn: "АВЕКМНОРСТУХ")
    
    /**
     */
    func removing(charsIn string: String) -> CharacterSet {
        var result = self
        result.remove(charactersIn: string)
        return result
    }
}
