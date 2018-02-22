//
//  AtomManager.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/22/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation
import UIKit

class AtomManager: NSObject {
    
    static var shared = AtomManager()
    
    private override init() {
        super.init()
        self.loadInformations()
    }
    
    public private(set) var atomColors: [String: UIColor] = [:]
    public let unknownColor = UIColor(rgbValues: 255, 20, 147)
    public private(set) var atomsInformations: [String: [String: Any]] = [:]
    
    func loadInformations() {
        guard let dataUrl = Bundle.main.url(forResource: "PeriodicTableData", withExtension: "json"),
            let dataData = try? Data(contentsOf: dataUrl),
            let jsonResult = try? JSONSerialization.jsonObject(with: dataData, options: []) else {
                return
        }
        if let array = jsonResult as? [Any] {
            for object in array {
                if let dico = object as? [String: Any],
                    let symbol = dico["symbol"] as? String {
                    self.atomsInformations[symbol.uppercased()] = dico
                    if let cpkHexColor = dico["cpkHexColor"] as? String,
                        let color = UIColor(hexString: cpkHexColor) {
                        self.atomColors[symbol.uppercased()] = color
                    }
                }
            }
        }
    }
    
}
