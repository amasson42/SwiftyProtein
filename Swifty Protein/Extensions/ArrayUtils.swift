//
//  ArrayUtils.swift
//  Swifty Protein
//
//  Created by Arthur Masson on 21/02/2018.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

public func ==(lhs: [String], rhs: [String]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for i in 0 ..< lhs.count {
        if lhs[i] != rhs[i] {
            return false
        }
    }
    return true
}
