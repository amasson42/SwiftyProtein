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
}
