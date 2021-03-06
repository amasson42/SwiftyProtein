//
//  Color.swift
//  Swifty Protein
//
//  Created by Arthur Masson on 21/02/2018.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(rgbValues r: Int, _ g: Int, _ b: Int) {
        self.init(red: CGFloat(r) / 256.0, green: CGFloat(g) / 256.0, blue: CGFloat(b) / 256.0, alpha: 1.0)
    }
    
    convenience init?(hexString string: String) {
        guard string.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: string.lowercased())
        scanner.scanLocation = 0
        scanner.scanHexInt64(&rgbValue)
        
        self.init(rgbValues: Int((rgbValue & 0xFF0000) >> 16),
                  Int((rgbValue & 0x00FF00) >> 8),
                  Int((rgbValue & 0x0000FF) >> 0))
    }
    
    func lightedWith(factor: CGFloat) -> UIColor {
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: factor * red, green: factor * green, blue: factor * blue, alpha: alpha)
    }
}
