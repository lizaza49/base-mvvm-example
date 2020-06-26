//
//  CG+UIView+Snapshot.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension CGContext {
    
    /**
     */
    static func create(size: CGSize) -> CGContext? {
        let scale = UIScreen.main.scale
        let space: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let context = CGContext(data: nil, width: Int(size.width * scale), height: Int(size.height * scale), bitsPerComponent: 8, bytesPerRow: Int(size.width * scale * 4), space: space, bitmapInfo: bitmapInfo.rawValue)
            else { return nil }
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        return context
    }
    
    /**
     */
    func getImage() -> UIImage? {
        guard let cgImage = makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

///
@objc extension UIView {
    
    /**
     */
    func snapshot() -> UIImage? {
        guard let context = CGContext.create(size: bounds.size) else { return nil }
        layer.render(in: context)
        return context.getImage()
    }
}

///
@objc extension CALayer {
    
    /**
     */
    func snapshot() -> UIImage? {
        guard let context = CGContext.create(size: self.bounds.size) else { return nil }
        self.render(in: context)
        return context.getImage()
    }
}
