//
//  ProteinClass.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

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
    var radius: Float = 0.0
    var conects: [Int] = []
    
    init(id: Int) {
        self.id = id
    }
}
