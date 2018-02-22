//
//  DateUtils.swift
//  Swifty Protein
//
//  Created by Arthur Masson on 21/02/2018.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

extension Date {
    
    static func date(fromString string: String, withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    func toString(withFormat string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = string
        return dateFormatter.string(from: self)
    }
}
