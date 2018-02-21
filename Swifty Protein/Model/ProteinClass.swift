//
//  ProteinClass.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation
import UIKit

// https://files.rcsb.org/ligands/view/**.xml

class ProteinHeader {
    
    var id: String
    var name: String = ""
    var formula: String = ""
    var type: String = ""
    var initialDate: Date = Date()
    var modifiedDate: Date = Date()
    var weight: Float = 0.0
    
    init(id: String) {
        self.id = id
    }
}

class ProteinData {
    
    static let atomColors: [String: UIColor] = [
        "H": .white,
        "C": .black,
        "N": UIColor.blue, // dark blue
        "O": .red,
        "F": .green,
        "Cl": .green,
        "Br": UIColor.red, // dark red
        "I": UIColor.magenta, // dark violet
        "He": .cyan,
        "Ne": .cyan,
        "Ar": .cyan,
        "Xe": .cyan,
        "Kr": .cyan,
        "P": .orange,
        "S": .yellow,
        "B": UIColor.purple, // pink salmon
        "Li": .magenta,
        "Na": .magenta,
        "K": .magenta,
        "Rb": .magenta,
        "Cs": .magenta,
        "Fr": .magenta,
        "Be": UIColor(rgbValues: 14, 117, 15),
        "Mg": UIColor(rgbValues: 14, 117, 15),
        "Ca": UIColor(rgbValues: 14, 117, 15),
        "Sr": UIColor(rgbValues: 14, 117, 15),
        "Ba": UIColor(rgbValues: 14, 117, 15),
        "Ra": UIColor(rgbValues: 14, 117, 15),
        "Ti": .gray,
        "Fe": UIColor.orange, // dark orange
    ]
    static let unknownColor = UIColor.purple
    
    unowned let header: ProteinHeader
    var atoms: [Atom] = []
    
    init (header: ProteinHeader) {
        self.header = header
    }
    
}

// https://files.rcsb.org/ligands/view/**_ideal.pdb
class Atom {
    var id: Int
    var identifier: String = ""
    var symbol: String = ""
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    var conects: [Int] = []
    
    init(id: Int) {
        self.id = id
    }
}

