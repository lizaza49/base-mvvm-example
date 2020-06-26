//
//  Color.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
final class Color {
    static let black = UIColor.black
    static let white = UIColor.white
    /// #9e0918
    static let cherry = UIColor(hex: 0x9e0918)
    /// #bf914d
    static let mustard = UIColor(hex: 0xbf914d)
    
    // MARK: Gray (sorted dark -> light)
    /// #333333
    static let theDarkestGray = UIColor(hex: 0x333333)
    /// #3c3c3c
    static let darkGray = UIColor(hex: 0x3c3c3c)
    /// #666666
    static let devilGray = UIColor(hex: 0x666666)
    /// #848484
    static let asphaltGray = UIColor(hex: 0x848484)
    /// #8e8e93
    static let loaderGray = UIColor(hex: 0x8e8e93)
    /// #8e8e93 alpha 0.1
    static let searchBarGray = UIColor(hex: 0x8e8e93).withAlphaComponent(0.1)
    /// #999999
    static let noteGray = UIColor(hex: 0x999999)
    /// #afafaf
    static let gray = UIColor(hex: 0xafafaf)
    /// #C6C6C6
    static let iconGray = UIColor(hex: 0xC6C6C6)
    /// #d4d4d4
    static let lightGray = UIColor(hex: 0xd4d4d4)
    /// #E7E7E7
    static let dummyView = UIColor(hex: 0xE7E7E7)
    /// #ebebeb
    static let shadeOfGray = UIColor(hex: 0xebebeb)
    /// #f7f7f7
    static let backgroundGray = UIColor(hex: 0xf7f7f7)
	///#adafaf
    static let lightBlueGray = UIColor(hex: 0xadafaf)
    /**
     */
    static func make(hex: String) -> UIColor? {
        return UIColor(withHexString: hex)
    }
}

//MARK: - Private
fileprivate extension UIColor {
    
    /**
     Makes UIColor with hex string
     */
    convenience init?(withHexString hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        switch cString.count {
        case 6:
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(1.0))
        case 8:
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0)
        default:
            let err = "probably invalid hex: \(hex)"
            DDLogError(context: .evna, message: "runtime_error", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
            return nil
        }
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: alpha)
    }
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
        let components = (
            R: r/255.0,
            G: g/255.0,
            B: b/255.0
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: a)
    }
}

///
extension UIColor {
    
    func toHex() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
