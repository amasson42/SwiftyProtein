//
//  RandomUtils.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/16/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

extension Int {
    static func random(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min)))
    }
}
